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
      UserRole.serviceProvider.toUpdateJson(),
      {'role': 'service_provider'},
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

  test('role labels distinguish customer, shop, and service accounts', () {
    expect(UserRole.parse(null).label, 'Customer');
    expect(UserRole.parse('customer').isCustomer, isTrue);
    expect(UserRole.parse('business_owner').label, 'Business owner');
    expect(UserRole.parse('service_provider').label, 'Service provider');
    expect(UserRole.parse('admin').label, 'Admin');
  });
}
