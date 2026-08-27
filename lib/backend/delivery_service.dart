import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/data/repositories/delivery_repository.dart';
import 'package:degloor_one/shared/delivery_assignment.dart';
import 'package:degloor_one/shared/delivery_partner.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';

class DeliveryService {
  DeliveryService({required DeliveryRepository repository})
      : _repository = repository;

  final DeliveryRepository _repository;

  static DeliveryService? _instance;

  static DeliveryService get instance {
    final bound = _instance;
    if (bound == null) {
      throw StateError('DeliveryService is not bound.');
    }
    return bound;
  }

  /// Called from the composition root with a concrete repository.
  static void bind(DeliveryRepository repository) {
    _instance = DeliveryService(repository: repository);
  }

  Future<DeliveryPartner?> partnerForUser(String userId) {
    return _repository.partnerForUser(userId);
  }

  Future<DeliveryPartner> registerPartner(String userId) {
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

  Future<DeliveryAssignment?> activeForPartner(String partnerId) {
    return _repository.activeForPartner(partnerId);
  }

  Future<PageResult<PlacedOrder>> readyOrders({
    PageQuery page = const PageQuery(),
  }) {
    return _repository.readyOrders(page: page);
  }

  Future<DeliveryAssignment?> activeAssignment(String orderId) {
    return _repository.activeAssignment(orderId);
  }

  Stream<List<DeliveryPartner>> watchPartner(String partnerId) {
    return _repository.watchPartner(partnerId);
  }

  Future<void> acceptOrder(String orderId) {
    return _repository.acceptOrder(orderId);
  }

  Future<void> confirmPickup(String assignmentId) {
    return _repository.confirmPickup(assignmentId);
  }

  Future<void> confirmDeliveryWithOtp({
    required String orderId,
    required String otp,
  }) {
    return _repository.confirmDeliveryWithOtp(orderId: orderId, otp: otp);
  }

  Future<void> updatePartnerLocation({
    required double latitude,
    required double longitude,
    String? partnerId,
  }) async {
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw Exception('Invalid coordinates');
    }
    await _repository.updateLocation(
      latitude: latitude,
      longitude: longitude,
      partnerId: partnerId,
    );
  }

  static bool canConfirmDelivery(String status) {
    final current = OrderLifecycle.normalizeStatus(status);
    return current == OrderLifecycle.ready ||
        current == OrderLifecycle.shipping ||
        current == OrderLifecycle.outForDelivery;
  }

  Future<String?> fetchMyDeliveryOtp(String orderId) {
    return OrderService.instance.deliveryOtp(orderId);
  }

  static String messageFor(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('delivery') && raw.contains('otp')) {
      return 'The delivery code is invalid or has expired.';
    }
    return AppLogger.userFacingMessage(error);
  }
}
