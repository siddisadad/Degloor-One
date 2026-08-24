import 'package:degloor_one/shared/shop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
