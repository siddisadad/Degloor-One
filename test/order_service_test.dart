import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
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
      totalAmount: 199,
      deliveryFee: 25,
      items: [
        {
          'product_id': ShowcaseCatalog.prodRice,
          'quantity': 1,
          'price': 120.0,
        },
      ],
    );

    expect(order['status'], OrderLifecycle.pending);
    expect(order['payment_status'], OrderLifecycle.unpaid);
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
}
