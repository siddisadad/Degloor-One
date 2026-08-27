import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/address_default_flag.dart';

void main() {
  test('default-flag writes only serialize is_default', () {
    expect(
      const AddressDefaultFlag(true).toUpdateJson(),
      {'is_default': true},
    );
    expect(
      const AddressDefaultFlag(false).toUpdateJson(),
      {'is_default': false},
    );
    expect(
      const AddressDefaultFlag(true).toUpdateJson().keys,
      isNot(contains('id')),
    );
    expect(
      const AddressDefaultFlag(true).toUpdateJson().containsKey('user_id'),
      isFalse,
    );
    expect(
      const AddressDefaultFlag(true).toUpdateJson().containsKey('created_at'),
      isFalse,
    );
  });
}
