import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/address_service.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('guest has home and work addresses', () async {
    final rows =
        await AddressService.instance.listForUser(GuestAuthUser.guestUid);
    expect(rows.map((row) => row.id), containsAll(['addr-home', 'addr-work']));
    expect(rows.where((row) => row.isDefault).single.id, 'addr-home');
  });

  test('empty user returns no addresses', () async {
    expect(await AddressService.instance.listForUser(''), isEmpty);
  });

  test('setDefault switches the guest default to work', () async {
    await AddressService.instance.setDefault(
      id: 'addr-work',
      userId: GuestAuthUser.guestUid,
    );
    final rows =
        await AddressService.instance.listForUser(GuestAuthUser.guestUid);
    expect(rows.firstWhere((row) => row.id == 'addr-work').isDefault, isTrue);
    expect(rows.firstWhere((row) => row.id == 'addr-home').isDefault, isFalse);
  });

  test('delete is scoped to the owner', () async {
    await expectLater(
      AddressService.instance.delete(
        id: 'addr-work',
        userId: ShowcaseCatalog.customer2,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Address not found'),
        ),
      ),
    );
    final stillThere =
        await AddressService.instance.listForUser(GuestAuthUser.guestUid);
    expect(stillThere.map((row) => row.id), contains('addr-work'));

    await AddressService.instance.delete(
      id: 'addr-work',
      userId: GuestAuthUser.guestUid,
    );
    final afterDelete =
        await AddressService.instance.listForUser(GuestAuthUser.guestUid);
    expect(afterDelete.map((row) => row.id), isNot(contains('addr-work')));
    expect(afterDelete.map((row) => row.id), contains('addr-home'));
  });

  test('add default unsets the previous default', () async {
    final added = await AddressService.instance.add(
      userId: GuestAuthUser.guestUid,
      title: 'Parents',
      addressText: 'Near temple, Degloor',
      latitude: 18.55,
      longitude: 77.58,
      isDefault: true,
    );
    final rows =
        await AddressService.instance.listForUser(GuestAuthUser.guestUid);
    expect(rows.where((row) => row.isDefault).single.id, added.id);
    expect(rows.firstWhere((row) => row.id == 'addr-home').isDefault, isFalse);
  });

  test('add and setDefault require sign-in', () async {
    await expectLater(
      AddressService.instance.add(
        userId: '',
        title: 'Home',
        addressText: 'Degloor',
        latitude: 18.55,
        longitude: 77.58,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Please sign in'),
        ),
      ),
    );
    await expectLater(
      AddressService.instance.setDefault(id: 'addr-home', userId: ''),
      throwsA(isA<Exception>()),
    );
    await expectLater(
      AddressService.instance.delete(id: 'addr-home', userId: ''),
      throwsA(isA<Exception>()),
    );
  });
}
