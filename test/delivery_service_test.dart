import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('messageFor prefers PostgrestException.message', () {
    const error = PostgrestException(
      message: 'Order is no longer available',
      code: 'P0001',
    );
    expect(DeliveryService.messageFor(error), 'Order is no longer available');
  });

  test('messageFor strips Exception prefixes from generic errors', () {
    expect(
      DeliveryService.messageFor(Exception('Invalid OTP')),
      'Invalid OTP',
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
    );
    final partners = ShowcaseCatalog.query(
      'delivery_partners',
      ShowcaseQuery()..eq('user_id', ShowcaseCatalog.riderId),
    );
    expect(partners, isNotEmpty);
    expect(partners.first['current_latitude'], 18.55);
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
