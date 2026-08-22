import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/backend/delivery_service.dart';
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
}
