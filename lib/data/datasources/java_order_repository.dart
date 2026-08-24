import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/core/api/order_api.dart';
import 'package:degloor_one/data/repositories/order_repository.dart';
import 'package:degloor_one/shared/checkout_line_item.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/order_status_change.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';

/// Order access through the Java API. Table rows stay on the server.
class JavaOrderRepository implements OrderRepository {
  static int javaPage(PageQuery page) {
    if (page.limit <= 0) return 0;
    return page.offset ~/ page.limit;
  }

  static List<Map<String, dynamic>> maps(dynamic raw) {
    final rows = raw is List ? raw : const [];
    return [
      for (final row in rows.whereType<Map>()) Map<String, dynamic>.from(row),
    ];
  }

  static List<PlacedOrder> ordersFromPage(Map<String, dynamic> data) {
    return [for (final row in maps(data['items'])) PlacedOrder.fromJson(row)];
  }

  Future<Map<String, dynamic>?> _orderJson(String orderId) async {
    try {
      return await OrderApi.byId(orderId);
    } on JavaApiException catch (error) {
      if (error.code == 'ORDER_NOT_FOUND' || error.code.contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<PageResult<PlacedOrder>> forUser(
    String userId, {
    PageQuery page = const PageQuery(),
  }) async {
    final data = await OrderApi.list(
      page: javaPage(page),
      size: page.limit,
    );
    final items = ordersFromPage(data)
        .where((order) => order.userId == userId)
        .toList();
    return PageResult(
      items: items,
      hasMore: data['hasMore'] == true,
    );
  }

  @override
  Future<PageResult<PlacedOrder>> forBusiness(
    String businessId, {
    PageQuery page = const PageQuery(),
  }) async {
    final data = await OrderApi.forShop(
      businessId,
      page: javaPage(page),
      size: page.limit,
    );
    final items = ordersFromPage(data)
        .where((order) => order.businessId == businessId)
        .toList();
    return PageResult(
      items: items,
      hasMore: data['hasMore'] == true,
    );
  }

  @override
  Future<int> pendingCount(String businessId) async {
    if (businessId.isEmpty) return 0;
    final data = await OrderApi.forShop(businessId, page: 0, size: 100);
    return ordersFromPage(data)
        .where((order) =>
            order.businessId == businessId &&
            OrderLifecycle.normalizeStatus(order.status) ==
                OrderLifecycle.pending)
        .length;
  }

  @override
  Future<PlacedOrder?> byId(String orderId) async {
    if (orderId.isEmpty) return null;
    final json = await _orderJson(orderId);
    return json == null ? null : PlacedOrder.fromJson(json);
  }

  @override
  Future<PlacedOrder?> forCustomer({
    required String orderId,
    required String userId,
  }) async {
    if (orderId.isEmpty || userId.isEmpty) return null;
    final order = await byId(orderId);
    if (order == null || order.userId != userId) return null;
    return order;
  }

  @override
  Future<List<OrderStatusChange>> historyFor(String orderId) async {
    if (orderId.isEmpty) return const [];
    final json = await _orderJson(orderId);
    if (json == null) return const [];
    final rows = maps(json['history']);
    return [
      for (var i = 0; i < rows.length; i++)
        OrderStatusChange.fromJson(rows[i], orderId: orderId, index: i),
    ];
  }

  @override
  Future<List<OrderLine>> itemsWithProducts(String orderId) async {
    if (orderId.isEmpty) return const [];
    final json = await _orderJson(orderId);
    if (json == null) return const [];
    return [
      for (final row in maps(json['items']))
        OrderLine.fromJson(row, orderId: orderId),
    ];
  }

  @override
  Stream<List<PlacedOrder>> watchBusiness(String businessId) {
    return Stream.fromFuture(
      forBusiness(businessId).then((page) => page.items),
    );
  }

  @override
  Stream<List<PlacedOrder>> watchUserOrder({
    required String orderId,
    required String userId,
  }) {
    return Stream.fromFuture(
      forCustomer(orderId: orderId, userId: userId).then(
        (order) => order == null ? const <PlacedOrder>[] : [order],
      ),
    );
  }

  @override
  Future<String> placeOrder({
    required String userId,
    required String businessId,
    required String addressId,
    required List<CheckoutLineItem> items,
    String paymentMethod = 'COD',
    String? cartId,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Please sign in to place an order');
    }
    final order = await OrderApi.checkout(
      addressId: addressId,
      paymentMethod: paymentMethod,
    );
    return '${order['id']}';
  }

  @override
  Future<void> cancelOrder({
    required String orderId,
    required String actorUserId,
    String? reason,
  }) {
    return OrderApi.cancel(orderId, reason: reason);
  }

  @override
  Future<void> updateOwnerStatus({
    required String orderId,
    required String nextStatus,
    required String ownerId,
  }) {
    return OrderApi.ownerStatus(orderId, nextStatus);
  }
}
