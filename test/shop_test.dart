import 'package:degloor_one/shared/shop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Shop.fromJson reads Java camelCase', () {
    final shop = Shop.fromJson({
      'id': 'biz-patil',
      'ownerId': 'user-1',
      'name': 'Patil Kirana',
      'categoryId': 'cat-grocery',
      'addressText': 'Near bus stand, Degloor',
      'phoneNumber': '+919890000001',
      'latitude': 18.55,
      'longitude': 77.58,
      'rating': 4.5,
      'open': true,
      'verified': true,
      'imageUrl': 'https://example.com/shop.png',
      'source': 'owner',
      'createdAt': '2026-08-24T10:00:00Z',
      'updatedAt': '2026-08-24T12:00:00Z',
      'hours': [
        {
          'dayOfWeek': 1,
          'openTime': '09:00:00',
          'closeTime': '21:00:00',
          'closed': false,
        },
      ],
    });
    expect(shop.id, 'biz-patil');
    expect(shop.name, 'Patil Kirana');
    expect(shop.photos, ['https://example.com/shop.png']);
    expect(shop.source, 'owner');
    expect(shop.hours, hasLength(1));
    expect(shop.hours.single.dayOfWeek, 1);
    expect(shop.updatedAt!.toUtc().hour, 12);
  });

  test('Shop.fromJson reads listing aliases', () {
    final shop = Shop.fromJson({
      'business_id': 'biz-kale',
      'business_name': 'Kale Kirana',
      'category_id': 'cat-grocery',
      'sub_category': 'kirana',
      'address': 'Lane 2, Degloor',
      'phone': '9890000008',
      'latitude': 18.55,
      'longitude': 77.58,
      'opening_hours': [
        {
          'dayOfWeek': 0,
          'openTime': '08:00:00',
          'closeTime': '20:00:00',
          'closed': false,
        },
      ],
      'photos': ['https://example.com/kale.png'],
      'rating': 4.1,
      'source': 'owner',
      'verified': true,
      'last_updated': '2026-08-24T10:00:00Z',
    });
    expect(shop.id, 'biz-kale');
    expect(shop.name, 'Kale Kirana');
    expect(shop.categoryId, 'cat-grocery');
    expect(shop.subcategory, 'kirana');
    expect(shop.addressText, 'Lane 2, Degloor');
    expect(shop.phoneNumber, '9890000008');
    expect(shop.photos, ['https://example.com/kale.png']);
    expect(shop.imageUrl, 'https://example.com/kale.png');
    expect(shop.isVerified, isTrue);
    expect(shop.source, 'owner');
    expect(shop.hours, hasLength(1));
    expect(shop.updatedAt!.toUtc().year, 2026);
  });

  test('Shop.fromJson accepts Java listing aliases', () {
    final shop = Shop.fromJson({
      'businessId': 'DEG-0001',
      'businessName': 'Sangmeshwar Mobile Shop',
      'category': 'Electronics',
      'categoryId': 'cat-electronics',
      'subCategory': 'Mobile Phones & Repair',
      'address': 'Tail Gali, Degloor',
      'phone': '+91 81499 76123',
      'rating': 4.5,
      'reviewCount': 0,
      'verificationStatus': 'PENDING_VERIFICATION',
      'verified': false,
      'currentlyOpen': true,
      'photos': ['https://example.com/shop.png'],
      'source': 'owner',
      'lastUpdated': '2026-08-24T10:00:00Z',
    });
    expect(shop.id, 'DEG-0001');
    expect(shop.name, 'Sangmeshwar Mobile Shop');
    expect(shop.categoryId, 'cat-electronics');
    expect(shop.categoryName, 'Electronics');
    expect(shop.subcategory, 'Mobile Phones & Repair');
    expect(shop.addressText, 'Tail Gali, Degloor');
    expect(shop.phoneNumber, '+91 81499 76123');
    expect(shop.isVerified, isFalse);
    expect(shop.verificationStatus, 'PENDING_VERIFICATION');
    expect(shop.currentlyOpen, isTrue);
    expect(shop.photos, ['https://example.com/shop.png']);
    expect(shop.imageUrl, 'https://example.com/shop.png');
    expect(shop.source, 'owner');
    expect(shop.updatedAt?.toUtc().year, 2026);
  });

  test('Shop.fromJson does not treat category name as categoryId', () {
    final shop = Shop.fromJson({
      'id': 'biz-1',
      'name': 'Patil Kirana',
      'category': 'Grocery',
    });
    expect(shop.categoryId, isNull);
    expect(shop.categoryName, 'Grocery');
  });
}
