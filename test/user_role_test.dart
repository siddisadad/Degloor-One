import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/user_role.dart';

void main() {
  test('role writes only serialize role', () {
    expect(
      UserRole.customer.toUpdateJson(),
      {'role': 'customer'},
    );
    expect(
      UserRole.businessOwner.toUpdateJson(),
      {'role': 'business_owner'},
    );
    expect(
      UserRole.customer.toUpdateJson().keys,
      isNot(contains('id')),
    );
    expect(
      UserRole.customer.toUpdateJson().containsKey('email'),
      isFalse,
    );
    expect(
      UserRole.customer.toUpdateJson().containsKey('created_at'),
      isFalse,
    );
  });
}
