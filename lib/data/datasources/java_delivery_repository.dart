import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/core/api/delivery_api.dart';
import 'package:degloor_one/data/repositories/delivery_repository.dart';
import 'package:degloor_one/shared/delivery_assignment.dart';
import 'package:degloor_one/shared/delivery_partner.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';

/// Delivery access through the Java API. Table rows stay on the server.
class JavaDeliveryRepository implements DeliveryRepository {
  static List<Map<String, dynamic>> maps(dynamic raw) {
    final rows = raw is List ? raw : const [];
    return [
      for (final row in rows.whereType<Map>()) Map<String, dynamic>.from(row),
    ];
  }

  Future<T?> _orMissing<T>(Future<T> future) async {
    try {
      return await future;
    } on JavaApiException catch (error) {
      if (error.code == 'PARTNER_NOT_FOUND' || error.code.contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<DeliveryPartner?> partnerForUser(String userId) async {
    if (userId.isEmpty) return null;
    final partner = await _orMissing(
      DeliveryApi.me().then(DeliveryPartner.fromJson),
    );
    if (partner == null || partner.userId != userId) return null;
    return partner;
  }

  @override
  Future<DeliveryPartner> registerPartner(String userId) async {
    return DeliveryPartner.fromJson(await DeliveryApi.register());
  }

  @override
  Future<void> setAvailability({
    required String partnerId,
    required bool available,
  }) {
    return DeliveryApi.setAvailability(available);
  }

  @override
  Future<DeliveryAssignment?> activeForPartner(String partnerId) async {
    if (partnerId.isEmpty) return null;
    final data = await _orMissing(DeliveryApi.myOrders());
    if (data == null) return null;
    final assigned = maps(data['assigned']);
    if (assigned.isEmpty) return null;
    return _assignmentFromOrder(assigned.first, partnerId);
  }

  @override
  Future<PageResult<PlacedOrder>> readyOrders({
    PageQuery page = const PageQuery(),
  }) async {
    final data = await _orMissing(DeliveryApi.myOrders());
    if (data == null) {
      return const PageResult(items: [], hasMore: false);
    }
    final orders = [
      for (final row in maps(data['ready'])) PlacedOrder.fromJson(row),
    ];
    final items = orders.skip(page.offset).take(page.limit).toList();
    return PageResult(
      items: items,
      hasMore: page.offset + items.length < orders.length,
    );
  }

  @override
  Future<DeliveryAssignment?> activeAssignment(String orderId) async {
    if (orderId.isEmpty) return null;
    final data = await _orMissing(DeliveryApi.myOrders());
    if (data == null) return null;
    for (final row in maps(data['assigned'])) {
      final assignment = _assignmentFromOrder(row, '');
      if (assignment.orderId == orderId) return assignment;
    }
    return null;
  }

  @override
  Stream<List<DeliveryPartner>> watchPartner(String partnerId) async* {
    if (partnerId.isEmpty) {
      yield const [];
      return;
    }
    try {
      final partner = DeliveryPartner.fromJson(await DeliveryApi.me());
      yield partner.id == partnerId ? [partner] : const [];
    } on JavaApiException catch (error) {
      if (error.code == 'PARTNER_NOT_FOUND' || error.code.contains('404')) {
        yield const [];
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> acceptOrder(String orderId) {
    return DeliveryApi.accept(orderId);
  }

  @override
  Future<void> confirmPickup(String assignmentId) {
    // Java line ids stay order ids. Showcase pickup uses the assignment row id.
    return DeliveryApi.pickup(assignmentId);
  }

  @override
  Future<void> confirmDeliveryWithOtp({
    required String orderId,
    required String otp,
  }) {
    return DeliveryApi.verifyOtp(orderId: orderId, otp: otp.trim());
  }

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? partnerId,
  }) {
    return DeliveryApi.updateLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }

  DeliveryAssignment _assignmentFromOrder(
    Map<String, dynamic> order,
    String partnerId,
  ) {
    final orderId = '${order['id'] ?? ''}';
    final status = OrderLifecycle.normalizeStatus('${order['status'] ?? ''}');
    final created = order['createdAt'];
    final partner = '${order['partnerId'] ?? partnerId}';
    return DeliveryAssignment(
      id: orderId,
      orderId: orderId,
      deliveryPartnerId: partner,
      status: status == OrderLifecycle.outForDelivery ? 'picked_up' : 'assigned',
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
