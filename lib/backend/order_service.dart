import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/data/repositories/order_repository.dart';
import 'package:degloor_one/shared/checkout_line_item.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/order_status_change.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';

class OrderOwnerActions {
  const OrderOwnerActions({
    required this.canAccept,
    required this.canMarkReady,
    required this.canCounterDeliver,
    required this.canCancel,
    required this.isTerminal,
  });

  final bool canAccept;
  final bool canMarkReady;
  final bool canCounterDeliver;
  final bool canCancel;
  final bool isTerminal;

  String get acceptStatus => OrderLifecycle.accepted;
  String get readyStatus => OrderLifecycle.ready;
  String get cancelStatus => OrderLifecycle.cancelled;
}

class OrderCustomerActions {
  const OrderCustomerActions({
    required this.canCancel,
    required this.isCancelled,
    required this.showDeliveryOtp,
    required this.showStepper,
    required this.stepperIndex,
  });

  final bool canCancel;
  final bool isCancelled;
  final bool showDeliveryOtp;
  final bool showStepper;
  final int stepperIndex;
}

class OrderService {
  OrderService({required OrderRepository repository})
      : _repository = repository;

  final OrderRepository _repository;

  static OrderService? _instance;

  static OrderService get instance {
    final bound = _instance;
    if (bound == null) {
      throw StateError('OrderService is not bound.');
    }
    return bound;
  }

  /// Called from the composition root with a concrete repository.
  static void bind(OrderRepository repository) {
    _instance = OrderService(repository: repository);
  }

  OrderOwnerActions ownerActions(String status) {
    return OrderOwnerActions(
      canAccept: OrderLifecycle.canTransition(
        from: status,
        to: OrderLifecycle.accepted,
      ),
      canMarkReady: OrderLifecycle.canTransition(
        from: status,
        to: OrderLifecycle.ready,
      ),
      canCounterDeliver:
          OrderLifecycle.normalizeStatus(status) == OrderLifecycle.ready,
      canCancel: OrderLifecycle.canOwnerCancel(status),
      isTerminal: OrderLifecycle.isTerminal(status),
    );
  }

  OrderCustomerActions customerActions(String status) {
    final current = OrderLifecycle.normalizeStatus(status);
    return OrderCustomerActions(
      canCancel: OrderLifecycle.canCustomerCancel(current),
      isCancelled: current == OrderLifecycle.cancelled,
      showDeliveryOtp: current != OrderLifecycle.pending &&
          current != OrderLifecycle.delivered &&
          current != OrderLifecycle.cancelled,
      showStepper: current != OrderLifecycle.cancelled,
      stepperIndex: OrderLifecycle.stepperIndex(current),
    );
  }

  String statusLabel(String status) => OrderLifecycle.label(status);

  Future<PageResult<PlacedOrder>> listForUser(
    String userId, {
    PageQuery page = const PageQuery(),
  }) async {
    if (userId.isEmpty) {
      return const PageResult(items: [], hasMore: false);
    }
    return _repository.forUser(userId, page: page);
  }

  Future<PageResult<PlacedOrder>> listForBusiness(
    String businessId, {
    PageQuery page = const PageQuery(),
  }) async {
    if (businessId.isEmpty) {
      return const PageResult(items: [], hasMore: false);
    }
    return _repository.forBusiness(businessId, page: page);
  }

  Future<int> pendingCount(String businessId) async {
    if (businessId.isEmpty) return 0;
    return _repository.pendingCount(businessId);
  }

  Future<PlacedOrder?> findById(String orderId) async {
    if (orderId.isEmpty) return null;
    return _repository.byId(orderId);
  }

  Future<PlacedOrder?> forCustomer({
    required String orderId,
    required String userId,
  }) async {
    if (orderId.isEmpty || userId.isEmpty) return null;
    return _repository.forCustomer(orderId: orderId, userId: userId);
  }

  Future<List<OrderStatusChange>> historyFor(String orderId) async {
    if (orderId.isEmpty) return const [];
    return _repository.historyFor(orderId);
  }

  Future<List<OrderLine>> itemsWithProducts(String orderId) async {
    if (orderId.isEmpty) return const [];
    return _repository.itemsWithProducts(orderId);
  }

  /// Customer tracking code. Partners cannot read this from the orders row.
  Future<String?> deliveryOtp(String orderId) async {
    if (orderId.isEmpty) return null;
    return _repository.deliveryOtp(orderId);
  }

  Stream<List<PlacedOrder>> watchBusiness(String businessId) {
    return _repository.watchBusiness(businessId);
  }

  Stream<List<PlacedOrder>> watchUserOrder({
    required String orderId,
    required String userId,
  }) {
    return _repository.watchUserOrder(orderId: orderId, userId: userId);
  }

  /// Checkout. Live and Java paths ignore client prices; showcase does the same.
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
    if (items.isEmpty) {
      throw Exception('Cart is empty');
    }
    return _repository.placeOrder(
      userId: userId,
      businessId: businessId,
      addressId: addressId,
      items: items,
      paymentMethod: paymentMethod,
      cartId: cartId,
    );
  }

  /// Widget checkout: strips client prices before [placeOrder].
  Future<String> placeOrderFromCart({
    required String userId,
    required String businessId,
    required String addressId,
    required List<CartLine> items,
    String paymentMethod = 'COD',
    String? cartId,
  }) {
    return placeOrder(
      userId: userId,
      businessId: businessId,
      addressId: addressId,
      items: CartService.checkoutItems(items),
      paymentMethod: paymentMethod,
      cartId: cartId,
    );
  }

  Future<void> cancelOrder({
    required String orderId,
    required String actorUserId,
    String? reason,
  }) {
    return _repository.cancelOrder(
      orderId: orderId,
      actorUserId: actorUserId,
      reason: reason,
    );
  }

  Future<void> updateOwnerStatus({
    required String orderId,
    required String nextStatus,
    required String ownerId,
  }) {
    return _repository.updateOwnerStatus(
      orderId: orderId,
      nextStatus: OrderLifecycle.normalizeStatus(nextStatus),
      ownerId: ownerId,
    );
  }
}
