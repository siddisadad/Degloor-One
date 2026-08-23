import 'package:degloor_one/backend/repositories/delivery_repository.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/core/api/delivery_api.dart';
import 'package:degloor_one/core/api/order_api.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class DeliveryService {
  DeliveryService({DeliveryRepository? repository})
      : _repository = repository ?? DeliveryRepository();

  final DeliveryRepository _repository;

  static final instance = DeliveryService();

  Future<DeliveryPartnersRow?> partnerForUser(String userId) {
    return _repository.partnerForUser(userId);
  }

  Future<DeliveryPartnersRow> registerPartner(String userId) {
    if (userId.isEmpty) {
      throw Exception('Please sign in to register as a delivery partner');
    }
    return _repository.registerPartner(userId);
  }

  Future<void> setAvailability({
    required String partnerId,
    required bool available,
    required bool verified,
  }) async {
    if (!available) {
      await _repository.setAvailability(
        partnerId: partnerId,
        available: false,
      );
      return;
    }
    if (!verified) {
      throw Exception(
        'Your account is pending verification. Please wait for admin approval.',
      );
    }
    await _repository.setAvailability(partnerId: partnerId, available: true);
  }

  Future<DeliveryAssignmentsRow?> activeForPartner(String partnerId) {
    return _repository.activeForPartner(partnerId);
  }

  Future<PageResult<OrdersRow>> readyOrders({
    PageQuery page = const PageQuery(),
  }) async {
    final rows = await _repository.readyOrders(page: page);
    return PageResult(items: rows, hasMore: rows.length >= page.limit);
  }

  static Future<DeliveryAssignmentsRow?> activeAssignment(String orderId) async {
    if (orderId.isEmpty) return null;
    final rows = await DeliveryAssignmentsTable().querySingleRow(
      queryFn: (q) => q.eq('order_id', orderId).neq('status', 'delivered'),
    );
    return rows.isEmpty ? null : rows.first;
  }

  static Stream<List<DeliveryPartnersRow>> watchPartner(String partnerId) {
    return DeliveryPartnersTable().stream(
      primaryKey: 'id',
      queryFn: (q) => q.eq('id', partnerId),
    );
  }

  static Future<void> acceptOrder(String orderId) {
    return _rpc('accept_delivery_order', {'p_order_id': orderId});
  }

  static Future<void> confirmPickup(String assignmentId) {
    return _rpc('confirm_delivery_pickup', {'p_assignment_id': assignmentId});
  }

  static Future<void> confirmDeliveryWithOtp({
    required String orderId,
    required String otp,
  }) {
    return _rpc('confirm_delivery_with_otp', {
      'p_order_id': orderId,
      'p_otp': otp,
    });
  }

  static Future<void> updatePartnerLocation({
    required double latitude,
    required double longitude,
    String? partnerId,
  }) async {
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      throw Exception('Invalid coordinates');
    }
    if (JavaApiConfig.enabled) {
      await DeliveryApi.updateLocation(latitude: latitude, longitude: longitude);
      return;
    }
    if (kUseShowcaseData) {
      final query = ShowcaseQuery();
      if (partnerId != null && partnerId.isNotEmpty) {
        query.eq('id', partnerId);
      } else {
        query.eq('user_id', ShowcaseCatalog.riderId);
      }
      ShowcaseCatalog.update(
        'delivery_partners',
        {
          'current_latitude': latitude,
          'current_longitude': longitude,
        },
        query,
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

  static bool canConfirmDelivery(String status) {
    final current = OrderLifecycle.normalizeStatus(status);
    return current == OrderLifecycle.ready ||
        current == OrderLifecycle.shipping ||
        current == OrderLifecycle.outForDelivery;
  }

  static Future<String?> fetchMyDeliveryOtp(String orderId) async {
    if (JavaApiConfig.enabled) {
      return OrderApi.deliveryOtp(orderId);
    }
    if (kUseShowcaseData) {
      final orders = ShowcaseCatalog.query(
        'orders',
        ShowcaseQuery()..eq('id', orderId),
      );
      if (orders.isEmpty) return null;
      final status = OrderLifecycle.normalizeStatus('${orders.first['status']}');
      if (OrderLifecycle.isTerminal(status)) return null;
      return orders.first['delivery_otp'] as String?;
    }
    final result = await SupaFlow.client.rpc(
      'get_my_delivery_otp',
      params: {'p_order_id': orderId},
    );
    return result as String?;
  }

  static String messageFor(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('delivery') && raw.contains('otp')) {
      return 'The delivery code is invalid or has expired.';
    }
    return AppLogger.userFacingMessage(error);
  }

  static Future<void> _rpc(String name, Map<String, dynamic> params) async {
    if (JavaApiConfig.enabled) {
      await _applyJavaRpc(name, params);
      return;
    }
    if (kUseShowcaseData) {
      _applyShowcaseRpc(name, params);
      return;
    }
    await SupaFlow.client.rpc(name, params: params);
  }

  static Future<void> _applyJavaRpc(String name, Map<String, dynamic> params) async {
    if (name == 'confirm_delivery_with_otp') {
      await DeliveryApi.verifyOtp(
        orderId: params['p_order_id'] as String,
        otp: '${params['p_otp']}'.trim(),
      );
      return;
    }
    if (name == 'accept_delivery_order') {
      await DeliveryApi.accept(params['p_order_id'] as String);
      return;
    }
    if (name == 'confirm_delivery_pickup') {
      await DeliveryApi.pickupAssignment('${params['p_assignment_id']}');
    }
  }

  static void _applyShowcaseRpc(String name, Map<String, dynamic> params) {
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
      if (!canConfirmDelivery(status)) {
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
