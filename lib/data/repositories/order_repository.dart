import 'package:degloor_one/shared/checkout_line_item.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/order_status_change.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';

/// Data access for shop orders. Screens go through [OrderService].
/// Concrete implementations map table rows or API JSON.
abstract class OrderRepository {
  Future<PageResult<PlacedOrder>> forUser(
    String userId, {
    PageQuery page = const PageQuery(),
  });

  Future<PageResult<PlacedOrder>> forBusiness(
    String businessId, {
    PageQuery page = const PageQuery(),
  });

  Future<int> pendingCount(String businessId);

  Future<PlacedOrder?> byId(String orderId);

  Future<PlacedOrder?> forCustomer({
    required String orderId,
    required String userId,
  });

  Future<List<OrderStatusChange>> historyFor(String orderId);

  Future<List<OrderLine>> itemsWithProducts(String orderId);

  Stream<List<PlacedOrder>> watchBusiness(String businessId);

  Stream<List<PlacedOrder>> watchUserOrder({
    required String orderId,
    required String userId,
  });

  Future<String> placeOrder({
    required String userId,
    required String businessId,
    required String addressId,
    required List<CheckoutLineItem> items,
    String paymentMethod = 'COD',
    String? cartId,
  });

  Future<void> cancelOrder({
    required String orderId,
    required String actorUserId,
    String? reason,
  });

  Future<void> updateOwnerStatus({
    required String orderId,
    required String nextStatus,
    required String ownerId,
  });
}
