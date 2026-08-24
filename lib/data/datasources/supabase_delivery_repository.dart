import 'package:degloor_one/backend/repositories/delivery_repository.dart'
    as tables;
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/data/datasources/supabase_order_maps.dart';
import 'package:degloor_one/data/repositories/delivery_repository.dart';
import 'package:degloor_one/shared/delivery_assignment.dart';
import 'package:degloor_one/shared/delivery_partner.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

/// Showcase or live table access for riders.
class SupabaseDeliveryRepository implements DeliveryRepository {
  SupabaseDeliveryRepository({tables.DeliveryRepository? inner})
      : _inner = inner ?? tables.DeliveryRepository();

  final tables.DeliveryRepository _inner;

  @override
  Future<DeliveryPartner?> partnerForUser(String userId) {
    return _inner.partnerForUser(userId);
  }

  @override
  Future<DeliveryPartner> registerPartner(String userId) {
    return _inner.registerPartner(userId);
  }

  @override
  Future<void> setAvailability({
    required String partnerId,
    required bool available,
  }) {
    return _inner.setAvailability(partnerId: partnerId, available: available);
  }

  @override
  Future<DeliveryAssignment?> activeForPartner(String partnerId) {
    return _inner.activeForPartner(partnerId);
  }

  @override
  Future<PageResult<PlacedOrder>> readyOrders({
    PageQuery page = const PageQuery(),
  }) async {
    final rows = await _inner.readyOrders(page: page);
    return PageResult(
      items: rows.map(placedOrderFromRow).toList(),
      hasMore: rows.length >= page.limit,
    );
  }

  @override
  Future<DeliveryAssignment?> activeAssignment(String orderId) {
    return _inner.activeAssignment(orderId);
  }

  @override
  Stream<List<DeliveryPartner>> watchPartner(String partnerId) {
    return _inner.watchPartner(partnerId);
  }

  @override
  Future<void> acceptOrder(String orderId) {
    return _rpc('accept_delivery_order', {'p_order_id': orderId});
  }

  @override
  Future<void> confirmPickup(String assignmentId) {
    return _rpc('confirm_delivery_pickup', {'p_assignment_id': assignmentId});
  }

  @override
  Future<void> confirmDeliveryWithOtp({
    required String orderId,
    required String otp,
  }) {
    return _rpc('confirm_delivery_with_otp', {
      'p_order_id': orderId,
      'p_otp': otp,
    });
  }

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? partnerId,
  }) async {
    if (kUseShowcaseData) {
      await _inner.updateLocation(
        latitude: latitude,
        longitude: longitude,
        partnerId: partnerId,
        userId: ShowcaseCatalog.riderId,
      );
      return;
    }
    await SupaFlow.client.rpc(
      'update_delivery_location',
      params: {
        'p_latitude': latitude,
        'p_longitude': longitude,
      },
    );
  }

  Future<void> _rpc(String name, Map<String, dynamic> params) async {
    if (kUseShowcaseData) {
      _applyShowcaseRpc(name, params);
      return;
    }
    await SupaFlow.client.rpc(name, params: params);
  }

  void _applyShowcaseRpc(String name, Map<String, dynamic> params) {
    if (name == 'confirm_delivery_with_otp') {
      final orderId = params['p_order_id'] as String;
      final otp = '${params['p_otp']}'.trim();
      final orders = ShowcaseCatalog.query(
        'orders',
        ShowcaseQuery()..eq('id', orderId),
      );
      if (orders.isEmpty) {
        throw Exception('Order not found');
      }
      final status = OrderLifecycle.normalizeStatus('${orders.first['status']}');
      if (status != OrderLifecycle.ready &&
          status != OrderLifecycle.shipping &&
          status != OrderLifecycle.outForDelivery) {
        throw Exception('Order is no longer active');
      }
      final expected = '${orders.first['delivery_otp'] ?? ''}'.trim();
      if (expected.isEmpty || expected != otp) {
        throw Exception('Invalid delivery OTP');
      }
      ShowcaseCatalog.update(
        'orders',
        {'status': OrderLifecycle.delivered},
        ShowcaseQuery()..eq('id', orderId),
      );
      ShowcaseCatalog.insert('order_status_history', {
        'order_id': orderId,
        'status': OrderLifecycle.delivered,
        'notes': 'Order delivered after OTP verification.',
      });
      return;
    }
    if (name == 'accept_delivery_order') {
      final orderId = params['p_order_id'] as String;
      final partners = ShowcaseCatalog.query(
        'delivery_partners',
        ShowcaseQuery()..eq('user_id', ShowcaseCatalog.riderId),
      );
      if (partners.isEmpty || partners.first['is_verified'] != true) {
        throw Exception('Not a verified delivery partner');
      }
      final partnerId = '${partners.first['id']}';
      final active = ShowcaseCatalog.query(
        'delivery_assignments',
        ShowcaseQuery()
          ..eq('delivery_partner_id', partnerId)
          ..neq('status', 'delivered'),
      );
      if (active.isNotEmpty) {
        throw Exception('You already have an active delivery');
      }
      final orders = ShowcaseCatalog.query(
        'orders',
        ShowcaseQuery()..eq('id', orderId),
      );
      if (orders.isEmpty ||
          OrderLifecycle.normalizeStatus('${orders.first['status']}') !=
              OrderLifecycle.ready) {
        throw Exception('Order is no longer available');
      }
      ShowcaseCatalog.update(
        'orders',
        {'status': OrderLifecycle.shipping},
        ShowcaseQuery()..eq('id', orderId),
      );
      ShowcaseCatalog.insert('delivery_assignments', {
        'order_id': orderId,
        'delivery_partner_id': partnerId,
        'status': 'assigned',
      });
      ShowcaseCatalog.insert('order_status_history', {
        'order_id': orderId,
        'status': OrderLifecycle.shipping,
        'notes': 'Order accepted by delivery partner.',
      });
      return;
    }
    if (name == 'confirm_delivery_pickup') {
      final assignmentId = params['p_assignment_id'] as String;
      final assignments = ShowcaseCatalog.query(
        'delivery_assignments',
        ShowcaseQuery()..eq('id', assignmentId),
      );
      if (assignments.isEmpty) {
        throw Exception('Pickup is not allowed for this assignment');
      }
      final orderId = '${assignments.first['order_id']}';
      ShowcaseCatalog.update(
        'delivery_assignments',
        {'status': 'picked_up'},
        ShowcaseQuery()..eq('id', assignmentId),
      );
      ShowcaseCatalog.update(
        'orders',
        {'status': OrderLifecycle.outForDelivery},
        ShowcaseQuery()..eq('id', orderId),
      );
      ShowcaseCatalog.insert('order_status_history', {
        'order_id': orderId,
        'status': OrderLifecycle.outForDelivery,
        'notes': 'Order picked up by delivery partner.',
      });
    }
  }
}
