import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/backend/repositories/order_repository.dart' as tables;
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/data/datasources/supabase_order_maps.dart';
import 'package:degloor_one/data/repositories/order_repository.dart';
import 'package:degloor_one/shared/checkout_line_item.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/order_status_change.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

/// Showcase or live table access for shop orders.
class SupabaseOrderRepository implements OrderRepository {
  SupabaseOrderRepository({tables.OrderRepository? inner})
      : _inner = inner ?? tables.OrderRepository();

  final tables.OrderRepository _inner;

  @override
  Future<PageResult<PlacedOrder>> forUser(
    String userId, {
    PageQuery page = const PageQuery(),
  }) async {
    final rows = await _inner.forUser(userId, page: page);
    return PageResult(
      items: rows.map(placedOrderFromRow).toList(),
      hasMore: rows.length >= page.limit,
    );
  }

  @override
  Future<PageResult<PlacedOrder>> forBusiness(
    String businessId, {
    PageQuery page = const PageQuery(),
  }) async {
    final rows = await _inner.forBusiness(businessId, page: page);
    return PageResult(
      items: rows.map(placedOrderFromRow).toList(),
      hasMore: rows.length >= page.limit,
    );
  }

  @override
  Future<int> pendingCount(String businessId) {
    return _inner.countForBusiness(
      businessId,
      status: OrderLifecycle.pending,
    );
  }

  @override
  Future<PlacedOrder?> byId(String orderId) async {
    final row = await _inner.byId(orderId);
    return row == null ? null : placedOrderFromRow(row);
  }

  @override
  Future<PlacedOrder?> forCustomer({
    required String orderId,
    required String userId,
  }) async {
    final row = await _inner.forCustomer(orderId: orderId, userId: userId);
    return row == null ? null : placedOrderFromRow(row);
  }

  @override
  Future<List<OrderStatusChange>> historyFor(String orderId) async {
    final rows = await _inner.historyFor(orderId);
    return rows.map(orderStatusChangeFromRow).toList();
  }

  @override
  Future<List<OrderLine>> itemsWithProducts(String orderId) async {
    if (orderId.isEmpty) return const [];
    if (kUseShowcaseData) {
      return ShowcaseCatalog.orderItemsWithProducts(orderId)
          .map(OrderLine.fromJoin)
          .toList();
    }
    final items = await SupaFlow.client
        .from('order_items')
        .select('*, products(*)')
        .eq('order_id', orderId);
    return List<Map<String, dynamic>>.from(items)
        .map(OrderLine.fromJoin)
        .toList();
  }

  @override
  Future<String?> deliveryOtp(String orderId) async {
    if (orderId.isEmpty) return null;
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

  @override
  Stream<List<PlacedOrder>> watchBusiness(String businessId) {
    return _inner.watchBusiness(businessId).map(
          (rows) => rows.map(placedOrderFromRow).toList(),
        );
  }

  @override
  Stream<List<PlacedOrder>> watchUserOrder({
    required String orderId,
    required String userId,
  }) {
    return _inner.watchUserOrder(orderId: orderId, userId: userId).map(
          (rows) => rows.map(placedOrderFromRow).toList(),
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
    if (kUseShowcaseData) {
      final order = placeShowcaseOrder(
        userId: userId,
        businessId: businessId,
        cartId: cartId ?? '',
        addressId: addressId,
        items: items,
        paymentMethod: paymentMethod,
      );
      return order['id'] as String;
    }

    final response = await SupaFlow.client.rpc(
      'place_order',
      params: {
        'p_business_id': businessId,
        'p_total_amount': 0,
        'p_delivery_address_id': addressId,
        'p_payment_method': paymentMethod,
        'p_items': items.map((item) => item.toRpcJson()).toList(),
      },
    );
    if (response == null) {
      throw Exception('Failed to place order (no response from server)');
    }
    return response.toString();
  }

  @override
  Future<void> cancelOrder({
    required String orderId,
    required String actorUserId,
    String? reason,
  }) async {
    if (kUseShowcaseData) {
      _cancelShowcase(
        orderId: orderId,
        actorUserId: actorUserId,
        reason: reason,
      );
      return;
    }
    await SupaFlow.client.rpc(
      'cancel_order',
      params: {
        'p_order_id': orderId,
        'p_reason': reason,
      },
    );
  }

  @override
  Future<void> updateOwnerStatus({
    required String orderId,
    required String nextStatus,
    required String ownerId,
  }) async {
    final status = OrderLifecycle.normalizeStatus(nextStatus);
    if (kUseShowcaseData) {
      _updateShowcaseStatus(
        orderId: orderId,
        nextStatus: status,
        ownerId: ownerId,
      );
      return;
    }
    await SupaFlow.client.rpc(
      'update_order_status',
      params: {
        'p_order_id': orderId,
        'p_status': status,
      },
    );
  }

  /// Local checkout used when the FlutterFlow host is down.
  /// Client [price] values are ignored; catalog prices win.
  static Map<String, dynamic> placeShowcaseOrder({
    required String userId,
    required String businessId,
    required String cartId,
    required String addressId,
    required List<CheckoutLineItem> items,
    String paymentMethod = 'COD',
    String deliveryOtp = '7392',
    double? totalAmount,
    double? deliveryFee,
  }) {
    var subtotal = 0.0;
    final priced = <Map<String, dynamic>>[];
    for (final item in items) {
      final productId = item.productId;
      final quantity = item.quantity;
      if (quantity <= 0) {
        throw Exception('Invalid quantity');
      }
      final products = ShowcaseCatalog.query(
        'products',
        ShowcaseQuery()..eq('id', productId),
      );
      if (products.isEmpty || products.first['business_id'] != businessId) {
        throw Exception('Product $productId is not sold by this business');
      }
      final product = products.first;
      if (product['is_available'] == false) {
        throw Exception('Product $productId is unavailable');
      }
      final unit = (product['price'] as num).toDouble();
      if (product['track_inventory'] == true) {
        final stock = (product['stock_quantity'] as num?)?.toInt() ?? 0;
        if (stock < quantity) {
          throw Exception('Insufficient stock for product $productId');
        }
        ShowcaseCatalog.update(
          'products',
          {'stock_quantity': stock - quantity},
          ShowcaseQuery()..eq('id', productId),
        );
      }
      subtotal += unit * quantity;
      priced.add({
        'product_id': productId,
        'quantity': quantity,
        'price': unit,
      });
    }

    final ownedAddress = ShowcaseCatalog.query(
      'addresses',
      ShowcaseQuery()
        ..eq('id', addressId)
        ..eq('user_id', userId),
    );
    if (ownedAddress.isEmpty) {
      throw Exception('Delivery address not found');
    }

    final fee = deliveryFee ?? 25.0;
    final order = ShowcaseCatalog.insert('orders', {
      'user_id': userId,
      'business_id': businessId,
      'total_amount': subtotal + fee,
      'status': OrderLifecycle.pending,
      'payment_status': OrderLifecycle.unpaid,
      'delivery_address_id': addressId,
      'delivery_fee': fee,
      'payment_method': paymentMethod,
      'delivery_otp': deliveryOtp,
    });
    for (final item in priced) {
      ShowcaseCatalog.insert('order_items', {
        'order_id': order['id'],
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price_at_purchase': item['price'],
      });
    }
    ShowcaseCatalog.insert('order_status_history', {
      'order_id': order['id'],
      'status': OrderLifecycle.pending,
      'notes': 'Order placed from showcase cart',
    });
    if (cartId.isNotEmpty) {
      ShowcaseCatalog.delete(
        'cart_items',
        ShowcaseQuery()..eq('cart_id', cartId),
      );
      ShowcaseCatalog.delete(
        'carts',
        ShowcaseQuery()..eq('id', cartId),
      );
    }
    NotificationService.notifyOrderStatusUpdate(
      userId: userId,
      orderId: order['id'] as String,
      status: OrderLifecycle.pending,
    );
    return order;
  }

  static void _cancelShowcase({
    required String orderId,
    required String actorUserId,
    String? reason,
  }) {
    final orders = ShowcaseCatalog.query(
      'orders',
      ShowcaseQuery()..eq('id', orderId),
    );
    if (orders.isEmpty) {
      throw Exception('Order not found');
    }
    final order = orders.first;
    final status = OrderLifecycle.normalizeStatus('${order['status']}');
    final isCustomer = order['user_id'] == actorUserId;
    final businesses = ShowcaseCatalog.query(
      'businesses',
      ShowcaseQuery()..eq('id', order['business_id']),
    );
    final isOwner =
        businesses.isNotEmpty && businesses.first['owner_id'] == actorUserId;

    if (!isCustomer && !isOwner) {
      throw Exception('Not allowed to cancel this order');
    }
    if (isCustomer && !isOwner && !OrderLifecycle.canCustomerCancel(status)) {
      throw Exception('Customers can cancel only while the order is pending');
    }
    if (isOwner && !OrderLifecycle.canOwnerCancel(status)) {
      throw Exception('Cannot cancel after a rider has been assigned');
    }

    final items = ShowcaseCatalog.query(
      'order_items',
      ShowcaseQuery()..eq('order_id', orderId),
    );
    for (final item in items) {
      final products = ShowcaseCatalog.query(
        'products',
        ShowcaseQuery()..eq('id', item['product_id']),
      );
      if (products.isEmpty || products.first['track_inventory'] != true) {
        continue;
      }
      final stock = (products.first['stock_quantity'] as num?)?.toInt() ?? 0;
      ShowcaseCatalog.update(
        'products',
        {'stock_quantity': stock + (item['quantity'] as num).toInt()},
        ShowcaseQuery()..eq('id', item['product_id']),
      );
    }

    ShowcaseCatalog.update(
      'orders',
      {'status': OrderLifecycle.cancelled},
      ShowcaseQuery()..eq('id', orderId),
    );
    ShowcaseCatalog.insert('order_status_history', {
      'order_id': orderId,
      'status': OrderLifecycle.cancelled,
      'notes': reason ?? 'Order cancelled',
    });
    NotificationService.notifyOrderStatusUpdate(
      userId: '${order['user_id']}',
      orderId: orderId,
      status: OrderLifecycle.cancelled,
    );
  }

  static void _updateShowcaseStatus({
    required String orderId,
    required String nextStatus,
    required String ownerId,
  }) {
    if (nextStatus == OrderLifecycle.cancelled) {
      _cancelShowcase(
          orderId: orderId, actorUserId: ownerId, reason: 'Cancelled by shop');
      return;
    }
    if (nextStatus == OrderLifecycle.delivered) {
      throw Exception('Use confirm_delivery_with_otp to mark delivered');
    }
    final orders = ShowcaseCatalog.query(
      'orders',
      ShowcaseQuery()..eq('id', orderId),
    );
    if (orders.isEmpty) {
      throw Exception('Order not found');
    }
    final businesses = ShowcaseCatalog.query(
      'businesses',
      ShowcaseQuery()..eq('id', orders.first['business_id']),
    );
    if (businesses.isEmpty || businesses.first['owner_id'] != ownerId) {
      throw Exception('Not allowed to update this order');
    }
    final current = OrderLifecycle.normalizeStatus('${orders.first['status']}');
    if (!OrderLifecycle.canTransition(from: current, to: nextStatus)) {
      throw Exception('Invalid status transition from $current to $nextStatus');
    }
    ShowcaseCatalog.update(
      'orders',
      {'status': nextStatus},
      ShowcaseQuery()..eq('id', orderId),
    );
    ShowcaseCatalog.insert('order_status_history', {
      'order_id': orderId,
      'status': nextStatus,
      'notes': 'Order status updated by business owner.',
    });
    NotificationService.notifyOrderStatusUpdate(
      userId: '${orders.first['user_id']}',
      orderId: orderId,
      status: nextStatus,
    );
  }
}
