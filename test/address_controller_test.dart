import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/features/profile/address_controller.dart';
import 'package:degloor_one/shared/saved_address.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('profile controller lists guest addresses through the service', () async {
    final rows =
        await AddressController.instance.listForUser(GuestAuthUser.guestUid);
    expect(rows, everyElement(isA<SavedAddress>()));
    expect(rows.map((row) => row.id), containsAll(['addr-home', 'addr-work']));
  });
}
