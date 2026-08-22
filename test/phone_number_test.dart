import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/phone_number.dart';

void main() {
  test('normalizes a 10-digit Indian number and rejects junk', () {
    expect(PhoneNumber.normalize('9876543210'), '+919876543210');
    expect(PhoneNumber.normalize('+91 98765 43210'), '+919876543210');
    expect(PhoneNumber.normalize('123'), isNull);
    expect(PhoneNumber.normalize(''), isNull);
    expect(PhoneNumber.normalize('abcdefghij'), isNull);
  });
}
