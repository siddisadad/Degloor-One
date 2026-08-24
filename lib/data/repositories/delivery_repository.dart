import 'package:degloor_one/shared/delivery_assignment.dart';
import 'package:degloor_one/shared/delivery_partner.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';

/// Data access for riders. Screens go through [DeliveryService].
/// Concrete implementations map table rows or API JSON.
abstract class DeliveryRepository {
  Future<DeliveryPartner?> partnerForUser(String userId);

  Future<DeliveryPartner> registerPartner(String userId);

  Future<void> setAvailability({
    required String partnerId,
    required bool available,
  });

  Future<DeliveryAssignment?> activeForPartner(String partnerId);

  Future<PageResult<PlacedOrder>> readyOrders({
    PageQuery page = const PageQuery(),
  });

  Future<DeliveryAssignment?> activeAssignment(String orderId);

  Stream<List<DeliveryPartner>> watchPartner(String partnerId);

  Future<void> acceptOrder(String orderId);

  /// Showcase uses the assignment row id. Java line ids stay order ids.
  Future<void> confirmPickup(String assignmentId);

  Future<void> confirmDeliveryWithOtp({
    required String orderId,
    required String otp,
  });

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? partnerId,
  });
}
