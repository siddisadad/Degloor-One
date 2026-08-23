import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/address_default_flag.dart';
import 'package:degloor_one/shared/address_draft.dart';

void main() {
  test('address drafts only serialize insert fields', () {
    const draft = AddressDraft(
      userId: 'user-1',
      title: 'Home',
      addressText: 'Lane 3, Degloor',
      latitude: 18.55,
      longitude: 77.58,
      defaultFlag: AddressDefaultFlag(true),
    );
    expect(draft.toInsertJson(), {
      'user_id': 'user-1',
      'title': 'Home',
      'address_text': 'Lane 3, Degloor',
      'latitude': 18.55,
      'longitude': 77.58,
      'is_default': true,
    });
    expect(
      draft.toInsertJson().keys,
      ['user_id', 'title', 'address_text', 'latitude', 'longitude', 'is_default'],
    );
    expect(draft.toInsertJson().containsKey('id'), isFalse);
    expect(draft.toInsertJson().containsKey('created_at'), isFalse);
  });

  test('insert can override the form default flag', () {
    const draft = AddressDraft(
      userId: 'user-1',
      title: 'Work',
      addressText: 'Market Yard',
      latitude: 18.55,
      longitude: 77.58,
    );
    expect(
      draft.toInsertJson(defaultFlag: const AddressDefaultFlag(true))['is_default'],
      isTrue,
    );
    expect(draft.toInsertJson()['is_default'], isFalse);
  });

  test('fromForm trims title and address and rejects empty fields', () {
    final draft = AddressDraft.fromForm(
      userId: 'user-1',
      title: '  Home  ',
      addressText: '  Degloor  ',
      latitude: 18.55,
      longitude: 77.58,
    );
    expect(draft.title, 'Home');
    expect(draft.addressText, 'Degloor');
    expect(draft.defaultFlag.isDefault, isFalse);
    expect(
      () => AddressDraft.fromForm(
        userId: 'user-1',
        title: '   ',
        addressText: 'Degloor',
        latitude: 18.55,
        longitude: 77.58,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('title'),
        ),
      ),
    );
    expect(
      () => AddressDraft.fromForm(
        userId: 'user-1',
        title: 'Home',
        addressText: '   ',
        latitude: 18.55,
        longitude: 77.58,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('address details'),
        ),
      ),
    );
  });

  test('fromForm rejects invalid coordinates', () {
    expect(
      () => AddressDraft.fromForm(
        userId: 'user-1',
        title: 'Home',
        addressText: 'Degloor',
        latitude: 120,
        longitude: 77.58,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('location'),
        ),
      ),
    );
  });
}
