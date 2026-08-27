import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/shop_draft.dart';

void main() {
  test('shop drafts only serialize register fields', () {
    final draft = ShopDraft.fromRegister(
      name: 'Kale Kirana',
      ownerName: 'Priya Kale',
      phone: '9890000008',
      categoryId: 'cat-grocery',
      latitude: 18.55,
      longitude: 77.58,
      addressText: 'Lane 2, Degloor',
    );
    expect(draft.toInsertJson(ownerId: 'user-1'), {
      'owner_id': 'user-1',
      'name': 'Kale Kirana',
      'owner_name': 'Priya Kale',
      'description': '',
      'phone_number': '9890000008',
      'whatsapp_number': '9890000008',
      'address_text': 'Lane 2, Degloor',
      'category_id': 'cat-grocery',
      'latitude': 18.55,
      'longitude': 77.58,
      'discovery_radius': 5,
      'is_verified': false,
      'source': 'owner',
    });
    expect(
      draft.toInsertJson(ownerId: 'user-1').keys,
      isNot(contains('id')),
    );
    expect(
      draft.toInsertJson(ownerId: 'user-1').containsKey('created_at'),
      isFalse,
    );
  });

  test('register draft serializes storefront and verification photos', () {
    final draft = ShopDraft.fromRegister(
      name: 'Kale Kirana',
      ownerName: 'Priya Kale',
      phone: '9890000008',
      categoryId: 'cat-grocery',
      latitude: 18.55,
      longitude: 77.58,
      imageUrl: 'https://cdn/store.jpg',
      photos: [
        'https://cdn/store.jpg',
        'https://cdn/interior.jpg',
        'https://cdn/doc.jpg',
      ],
    );
    expect(draft.toInsertJson(ownerId: 'user-1')['image_url'],
        'https://cdn/store.jpg');
    expect(draft.toInsertJson(ownerId: 'user-1')['photos'], [
      'https://cdn/store.jpg',
      'https://cdn/interior.jpg',
      'https://cdn/doc.jpg',
    ]);
  });

  test('whatsapp falls back to phone and rejects empty register fields', () {
    final draft = ShopDraft.fromRegister(
      name: '  Shop  ',
      ownerName: '  Owner  ',
      phone: ' 9890 ',
      categoryId: 'cat-1',
      latitude: 18.55,
      longitude: 77.58,
      whatsappNumber: ' 9891 ',
    );
    expect(draft.name, 'Shop');
    expect(draft.whatsappNumber, '9891');
    expect(
      ShopDraft.fromRegister(
        name: 'Shop',
        ownerName: 'Owner',
        phone: '9890',
        categoryId: 'cat-1',
        latitude: 18.55,
        longitude: 77.58,
      ).whatsappNumber,
      '9890',
    );
    expect(
      () => ShopDraft.fromRegister(
        name: '  ',
        ownerName: 'Owner',
        phone: '9890',
        categoryId: 'cat-1',
        latitude: 18.55,
        longitude: 77.58,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('required fields'),
        ),
      ),
    );
    expect(
      () => ShopDraft.fromRegister(
        name: 'Shop',
        ownerName: 'Owner',
        phone: '9890',
        categoryId: 'cat-1',
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

  test('profile update stays off id, owner, and verification', () {
    final draft = ShopDraft.fromProfile(
      name: 'Patil Kirana Plus',
      ownerName: 'Ramesh',
      description: 'Groceries',
      phoneNumber: '9890',
      whatsappNumber: '9891',
      addressText: 'Main Road',
      discoveryRadius: 8,
      imageUrl: 'https://img',
    );
    expect(draft.toUpdateJson(), {
      'name': 'Patil Kirana Plus',
      'owner_name': 'Ramesh',
      'description': 'Groceries',
      'phone_number': '9890',
      'whatsapp_number': '9891',
      'address_text': 'Main Road',
      'discovery_radius': 8,
      'image_url': 'https://img',
      'photos': ['https://img'],
    });
    expect(
      draft.toUpdateJson().keys,
      isNot(contains('id')),
    );
    expect(draft.toUpdateJson().containsKey('owner_id'), isFalse);
    expect(draft.toUpdateJson().containsKey('is_verified'), isFalse);
    expect(draft.toUpdateJson().containsKey('category_id'), isFalse);
    expect(draft.toUpdateJson().containsKey('latitude'), isFalse);
    expect(draft.toUpdateJson().containsKey('created_at'), isFalse);
  });

  test('fromProfile rejects an empty name', () {
    expect(
      () => ShopDraft.fromProfile(name: '   '),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Business name'),
        ),
      ),
    );
  });

  test('cityId is serialized when present', () {
    final registerDraft = ShopDraft.fromRegister(
      name: 'Shop',
      ownerName: 'Owner',
      phone: '9890',
      categoryId: 'cat-1',
      latitude: 18.55,
      longitude: 77.58,
      cityId: 'city-123',
    );
    expect(registerDraft.toInsertJson(ownerId: 'user-1')['city_id'], 'city-123');

    final profileDraft = ShopDraft.fromProfile(
      name: 'Shop',
      cityId: 'city-456',
    );
    expect(profileDraft.toUpdateJson()['city_id'], 'city-456');
  });
}
