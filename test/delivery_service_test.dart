import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/delivery_assignment.dart';
import 'package:degloor_one/shared/delivery_partner.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/placed_order.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  test('messageFor hides PostgrestException internals', () {
    const error = PostgrestException(
      message: 'permission denied for table orders',
      code: 'PGRST301',
    );
    expect(
      DeliveryService.messageFor(error),
      'Something went wrong. Please try again.',
    );
  });

  test('messageFor maps OTP failures to a customer sentence', () {
    expect(
      DeliveryService.messageFor(Exception('Invalid delivery OTP')),
      'The delivery code is invalid or has expired.',
    );
  });

  test('partner location rejects invalid coordinates', () async {
    await expectLater(
      DeliveryService.instance
          .updatePartnerLocation(latitude: 120, longitude: 77),
      throwsA(isA<Exception>()),
    );
  });

  test('partner location writes showcase coordinates', () async {
    ShowcaseCatalog.reset();
    await DeliveryService.instance.updatePartnerLocation(
      latitude: 18.55,
      longitude: 77.58,
      partnerId: 'dp-amit',
    );
    final partners = ShowcaseCatalog.query(
      'delivery_partners',
      ShowcaseQuery()..eq('id', 'dp-amit'),
    );
    expect(partners, isNotEmpty);
    expect(partners.first['current_latitude'], 18.55);
  });

  test('active assignment is scoped to the order', () async {
    ShowcaseCatalog.reset();
    final assignment = await DeliveryService.instance.activeAssignment(
      ShowcaseCatalog.orderOut,
    );
    expect(assignment, isA<DeliveryAssignment>());
    expect(assignment, isNot(isA<DeliveryAssignmentsRow>()));
    expect(assignment?.id, 'da-1');
    expect(
      await DeliveryService.instance.activeAssignment('order-pending'),
      isNull,
    );
  });

  test('accept only claims ready orders', () async {
    ShowcaseCatalog.reset();
    await expectLater(
      DeliveryService.instance.acceptOrder(ShowcaseCatalog.orderOut),
      throwsA(isA<Exception>()),
    );
    expect(
      DeliveryService.canConfirmDelivery(OrderLifecycle.outForDelivery),
      isTrue,
    );
    expect(
      DeliveryService.canConfirmDelivery(OrderLifecycle.cancelled),
      isFalse,
    );
  });

  test('partner lookup and ready orders use the catalog', () async {
    ShowcaseCatalog.reset();
    final rider = await DeliveryService.instance.partnerForUser(
      ShowcaseCatalog.riderId,
    );
    expect(rider, isA<DeliveryPartner>());
    expect(rider, isNot(isA<DeliveryPartnersRow>()));
    expect(rider?.id, 'dp-amit');
    expect(rider?.isVerified, isTrue);

    expect(
      await DeliveryService.instance.partnerForUser(GuestAuthUser.guestUid),
      isNull,
    );

    final ready = await DeliveryService.instance.readyOrders();
    expect(ready.items, everyElement(isA<PlacedOrder>()));
    expect(ready.items, isNot(anyElement(isA<OrdersRow>())));
    expect(
        ready.items.map((row) => row.id), contains(ShowcaseCatalog.orderReady));
    expect(
      ready.items.every((row) => row.status == OrderLifecycle.ready),
      isTrue,
    );
  });

  test('active assignment for the rider is the out-for-delivery job', () async {
    ShowcaseCatalog.reset();
    final assignment =
        await DeliveryService.instance.activeForPartner('dp-amit');
    expect(assignment, isA<DeliveryAssignment>());
    expect(assignment, isNot(isA<DeliveryAssignmentsRow>()));
    expect(assignment?.id, 'da-1');
    expect(assignment?.orderId, ShowcaseCatalog.orderOut);
  });

  test('availability stays off until the partner is verified', () async {
    ShowcaseCatalog.reset();
    final created = await DeliveryService.instance.registerPartner(
      GuestAuthUser.guestUid,
    );
    expect(created, isA<DeliveryPartner>());
    expect(created, isNot(isA<DeliveryPartnersRow>()));
    expect(created.isVerified, isFalse);
    await expectLater(
      DeliveryService.instance.setAvailability(
        partnerId: created.id,
        available: true,
        verified: created.isVerified,
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('accept writes an assignment after the current job is finished',
      () async {
    ShowcaseCatalog.reset();
    await expectLater(
      DeliveryService.instance.acceptOrder(ShowcaseCatalog.orderReady),
      throwsA(isA<Exception>()),
    );

    ShowcaseCatalog.update(
      'delivery_assignments',
      {'status': 'delivered'},
      ShowcaseQuery()..eq('id', 'da-1'),
    );
    await DeliveryService.instance.acceptOrder(ShowcaseCatalog.orderReady);
    final claimed = await DeliveryService.instance.activeForPartner('dp-amit');
    expect(claimed?.orderId, ShowcaseCatalog.orderReady);
    expect(claimed?.status, 'assigned');
    expect(
      ShowcaseCatalog.query(
        'orders',
        ShowcaseQuery()..eq('id', ShowcaseCatalog.orderReady),
      ).single['status'],
      OrderLifecycle.shipping,
    );
  });

  test('watchPartner streams the assigned rider', () async {
    ShowcaseCatalog.reset();
    final assignment = await DeliveryService.instance.activeAssignment(
      ShowcaseCatalog.orderOut,
    );
    expect(assignment?.deliveryPartnerId, 'dp-amit');
    final partners = await DeliveryService.instance
        .watchPartner(assignment!.deliveryPartnerId)
        .first;
    expect(partners, everyElement(isA<DeliveryPartner>()));
    expect(partners, isNot(anyElement(isA<DeliveryPartnersRow>())));
    expect(partners.single.id, 'dp-amit');
  });

  test('fetchMyDeliveryOtp returns the showcase code for an active order',
      () async {
    ShowcaseCatalog.reset();
    expect(
      await DeliveryService.instance
          .fetchMyDeliveryOtp(ShowcaseCatalog.orderOut),
      '4821',
    );
    expect(
      await DeliveryService.instance.fetchMyDeliveryOtp('order-pending'),
      '2201',
    );
    expect(
      await DeliveryService.instance.fetchMyDeliveryOtp('missing-order'),
      isNull,
    );
  });

  test('Java partner and assignment JSON map to domain types', () {
    final partner = DeliveryPartner.fromJson({
      'id': 'dp-amit',
      'userId': 'rider-1',
      'vehicleType': 'bike',
      'vehicleNumber': 'MH26AB1234',
      'available': true,
      'verified': true,
      'currentLatitude': 18.55,
      'currentLongitude': 77.58,
    });
    expect(partner, isA<DeliveryPartner>());
    expect(partner.id, 'dp-amit');
    expect(partner.userId, 'rider-1');
    expect(partner.isAvailable, isTrue);
    expect(partner.isVerified, isTrue);
    expect(partner.currentLatitude, 18.55);

    final assignment = DeliveryAssignment.fromJson({
      'id': 'da-1',
      'orderId': 'order-out',
      'partnerId': 'dp-amit',
      'status': 'picked_up',
      'createdAt': '2026-08-24T10:00:00Z',
    });
    expect(assignment, isA<DeliveryAssignment>());
    expect(assignment.id, 'da-1');
    expect(assignment.orderId, 'order-out');
    expect(assignment.deliveryPartnerId, 'dp-amit');
    expect(assignment.status, 'picked_up');

    final order = PlacedOrder.fromJson({
      'id': 'order-ready',
      'userId': 'cust-1',
      'businessId': 'biz-1',
      'totalAmount': 120,
      'status': 'ready',
      'paymentStatus': 'paid',
      'createdAt': '2026-08-24T10:00:00Z',
    });
    expect(order, isA<PlacedOrder>());
    expect(order.id, 'order-ready');
    expect(order.totalAmount, 120);
    expect(order.status, 'ready');
  });
}
