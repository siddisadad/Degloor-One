import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/core/error_handler.dart';

void main() {
  test('known cart codes become customer sentences', () {
    expect(
      AppLogger.userFacingMessage(Exception('CART_STOCK')),
      'Not enough stock for this item.',
    );
    expect(
      AppLogger.userFacingMessage('PostgrestException(message: JWT expired)'),
      'Something went wrong. Please try again.',
    );
  });

  test('order create fallback hides SQL', () {
    expect(
      AppLogger.userFacingMessage(
        'PostgrestException(message: duplicate key value violates unique constraint)',
        fallback: 'Unable to place the order. Please try again.',
      ),
      'Unable to place the order. Please try again.',
    );
  });

  test('generic sanitizer does not steal phone OTP errors', () {
    expect(
      AppLogger.userFacingMessage(Exception('Invalid OTP')),
      'Invalid OTP',
    );
  });
}
