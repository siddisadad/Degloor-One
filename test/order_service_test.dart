import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('showcase checkout writes pending / unpaid and clears the cart', () {
    expect(kUseShowcaseData, isTrue);
    final order = OrderService.placeShowcaseOrder(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
      cartId: ShowcaseCatalog.cartGuest,
      addressId: 'addr-home',
      totalAmount: 1,
      deliveryFee: 25,
      items: [
        {
          'product_id': ShowcaseCatalog.prodRice,
          'quantity': 1,
          'price': 1.0,
        },
      ],
    );

    expect(order['status'], OrderLifecycle.pending);
    expect(order['payment_status'], OrderLifecycle.unpaid);
    expect(order['total_amount'], 145.0);
    expect(
      ShowcaseCatalog.query(
        'order_items',
        ShowcaseQuery()..eq('order_id', order['id']),
      ).single['price_at_purchase'],
      120.0,
    );
    expect(
      ShowcaseCatalog.query(
        'carts',
        ShowcaseQuery()..eq('id', ShowcaseCatalog.cartGuest),
      ),
      isEmpty,
    );
    expect(
      ShowcaseCatalog.query(
        'order_items',
        ShowcaseQuery()..eq('order_id', order['id']),
      ),
      hasLength(1),
    );
  });

  test('showcase delivery OTP marks the order delivered', () async {
    await DeliveryService.confirmDeliveryWithOtp(
      orderId: ShowcaseCatalog.orderOut,
      otp: '4821',
    );
    final orders = ShowcaseCatalog.query(
      'orders',
      ShowcaseQuery()..eq('id', ShowcaseCatalog.orderOut),
    );
    expect(orders.single['status'], OrderLifecycle.delivered);
  });

  test('showcase delivery OTP rejects a wrong code', () async {
    await expectLater(
      DeliveryService.confirmDeliveryWithOtp(
        orderId: ShowcaseCatalog.orderOut,
        otp: '0000',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('showcase order stream updates after delivery OTP', () async {
    final statuses = <String>[];
    final delivered = Completer<void>();
    final sub = OrdersTable()
        .stream(
          primaryKey: 'id',
          queryFn: (q) => q.eq('id', ShowcaseCatalog.orderOut),
        )
        .listen((rows) {
      if (rows.isEmpty) return;
      statuses.add(rows.first.status);
      if (rows.first.status == OrderLifecycle.delivered &&
          !delivered.isCompleted) {
        delivered.complete();
      }
    });

    await Future<void>.delayed(Duration.zero);
    expect(statuses, isNotEmpty);
    expect(statuses.first, isNot(OrderLifecycle.delivered));

    await DeliveryService.confirmDeliveryWithOtp(
      orderId: ShowcaseCatalog.orderOut,
      otp: '4821',
    );
    await delivered.future.timeout(const Duration(seconds: 2));
    expect(statuses.last, OrderLifecycle.delivered);
    await sub.cancel();
  });

  test('showcase checkout rejects a client-supplied price and uses catalog stock',
      () async {
    final rice = ShowcaseCatalog.query(
      'products',
      ShowcaseQuery()..eq('id', ShowcaseCatalog.prodRice),
    ).single;
    final stockBefore = rice['stock_quantity'] as int;

    final order = await OrderService.instance.placeOrder(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
      addressId: 'addr-home',
      cartId: ShowcaseCatalog.cartGuest,
      items: [
        {
          'product_id': ShowcaseCatalog.prodRice,
          'quantity': 2,
          'price': 1.0,
        },
      ],
    );

    final items = ShowcaseCatalog.query(
      'order_items',
      ShowcaseQuery()..eq('order_id', order),
    );
    expect(items.single['price_at_purchase'], 120.0);
    expect(
      ShowcaseCatalog.query(
        'products',
        ShowcaseQuery()..eq('id', ShowcaseCatalog.prodRice),
      ).single['stock_quantity'],
      stockBefore - 2,
    );
  });

  test('customer can cancel a pending order and stock is restored', () async {
    final order = OrderService.placeShowcaseOrder(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
      cartId: ShowcaseCatalog.cartGuest,
      addressId: 'addr-home',
      items: [
        {
          'product_id': ShowcaseCatalog.prodRice,
          'quantity': 1,
        },
      ],
    );
    final stockAfterPlace = ShowcaseCatalog.query(
      'products',
      ShowcaseQuery()..eq('id', ShowcaseCatalog.prodRice),
    ).single['stock_quantity'] as int;

    await OrderService.instance.cancelOrder(
      orderId: order['id'] as String,
      actorUserId: GuestAuthUser.guestUid,
    );

    expect(
      ShowcaseCatalog.query(
        'orders',
        ShowcaseQuery()..eq('id', order['id']),
      ).single['status'],
      OrderLifecycle.cancelled,
    );
    expect(
      ShowcaseCatalog.query(
        'products',
        ShowcaseQuery()..eq('id', ShowcaseCatalog.prodRice),
      ).single['stock_quantity'],
      stockAfterPlace + 1,
    );
  });

  test('owner cannot skip from pending to ready', () async {
    await expectLater(
      OrderService.instance.updateOwnerStatus(
        orderId: 'order-pending',
        nextStatus: OrderLifecycle.ready,
        ownerId: GuestAuthUser.guestUid,
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('owner cannot cancel after a rider is assigned', () async {
    await expectLater(
      OrderService.instance.cancelOrder(
        orderId: ShowcaseCatalog.orderOut,
        actorUserId: GuestAuthUser.guestUid,
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('customer order pages stay scoped to the signed-in user', () async {
    final page = await OrderService.instance.listForUser(
      GuestAuthUser.guestUid,
      page: const PageQuery(limit: 1),
    );
    expect(page.items, hasLength(1));
    expect(page.hasMore, isTrue);
    expect(
      page.items.every((row) => row.userId == GuestAuthUser.guestUid),
      isTrue,
    );

    final own = await OrderService.instance.forCustomer(
      orderId: ShowcaseCatalog.orderOut,
      userId: GuestAuthUser.guestUid,
    );
    expect(own?.id, ShowcaseCatalog.orderOut);

    final other = await OrderService.instance.forCustomer(
      orderId: ShowcaseCatalog.orderOut,
      userId: ShowcaseCatalog.customer2,
    );
    expect(other, isNull);
  });

  test('shop orders paginate and line items join products', () async {
    final page = await OrderService.instance.listForBusiness(
      ShowcaseCatalog.bizPatil,
      page: const PageQuery(limit: 1),
    );
    expect(page.items, hasLength(1));
    expect(page.hasMore, isTrue);
    expect(
      page.items.every((row) => row.businessId == ShowcaseCatalog.bizPatil),
      isTrue,
    );

    final items = await OrderService.instance.itemsWithProducts(
      ShowcaseCatalog.orderOut,
    );
    expect(items, isNotEmpty);
    expect(items.first['products'], isA<Map<String, dynamic>>());
  });

  test('pending count is scoped to the shop and pending status', () async {
    expect(
      await OrderService.instance.pendingCount(ShowcaseCatalog.bizPatil),
      1,
    );
    expect(
      await OrderService.instance.pendingCount(ShowcaseCatalog.bizHotel),
      0,
    );
    expect(await OrderService.instance.pendingCount(''), 0);
  });
}
