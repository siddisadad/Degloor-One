import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      DeliveryService.updatePartnerLocation(latitude: 120, longitude: 77),
      throwsA(isA<Exception>()),
    );
  });

  test('partner location writes showcase coordinates', () async {
    ShowcaseCatalog.reset();
    await DeliveryService.updatePartnerLocation(
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
    final assignment = await DeliveryService.activeAssignment(
      ShowcaseCatalog.orderOut,
    );
    expect(assignment?.id, 'da-1');
    expect(
      await DeliveryService.activeAssignment('order-pending'),
      isNull,
    );
  });

  test('accept only claims ready orders', () async {
    ShowcaseCatalog.reset();
    await expectLater(
      DeliveryService.acceptOrder(ShowcaseCatalog.orderOut),
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
}
