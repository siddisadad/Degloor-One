import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';

/// Data access for orders. Widgets should go through [OrderService].
class OrderRepository {
  Future<List<OrdersRow>> forUser(
    String userId, {
    PageQuery page = const PageQuery(),
  }) {
    return OrdersTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId).order('created_at', ascending: false),
      limit: page.limit,
      offset: page.offset,
    );
  }

  Future<List<OrdersRow>> forBusiness(
    String businessId, {
    PageQuery page = const PageQuery(),
  }) {
    return OrdersTable().queryRows(
      queryFn: (q) =>
          q.eq('business_id', businessId).order('created_at', ascending: false),
      limit: page.limit,
      offset: page.offset,
    );
  }

  Future<int> countForBusiness(
    String businessId, {
    required String status,
  }) async {
    if (businessId.isEmpty || status.isEmpty) return 0;
    final rows = await OrdersTable().queryRows(
      queryFn: (q) => q.eq('business_id', businessId).eq('status', status),
    );
    return rows.length;
  }

  Future<OrdersRow?> byId(String orderId) async {
    final rows = await OrdersTable().queryRows(
      queryFn: (q) => q.eq('id', orderId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<OrdersRow?> forCustomer({
    required String orderId,
    required String userId,
  }) async {
    if (orderId.isEmpty || userId.isEmpty) return null;
    final rows = await OrdersTable().queryRows(
      queryFn: (q) => q.eq('id', orderId).eq('user_id', userId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Stream<List<OrdersRow>> watchBusiness(String businessId) {
    return OrdersTable().stream(
      primaryKey: 'id',
      queryFn: (q) => q.eq('business_id', businessId).order('created_at'),
    );
  }

  Stream<List<OrdersRow>> watchUserOrder({
    required String orderId,
    required String userId,
  }) {
    return OrdersTable().stream(
      primaryKey: 'id',
      queryFn: (q) => q.eq('id', orderId).eq('user_id', userId),
    );
  }

  Future<List<OrderItemsRow>> itemsFor(String orderId) {
    return OrderItemsTable().queryRows(
      queryFn: (q) => q.eq('order_id', orderId),
    );
  }

  Future<List<OrderStatusHistoryRow>> historyFor(String orderId) {
    return OrderStatusHistoryTable().queryRows(
      queryFn: (q) =>
          q.eq('order_id', orderId).order('created_at', ascending: false),
    );
  }
}
