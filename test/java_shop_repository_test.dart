import 'package:degloor_one/data/datasources/java_shop_repository.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Java shop JSON maps to Shop', () {
    final row = JavaShopRepository.fromJson({
      'id': 'biz-patil',
      'ownerId': 'user-1',
      'name': 'Patil Kirana',
      'ownerName': 'Ramesh Patil',
      'description': 'Daily groceries',
      'categoryId': 'cat-grocery',
      'cityId': 'city-degloor',
      'addressText': 'Near bus stand, Degloor',
      'whatsappNumber': '+919890000001',
      'phoneNumber': '+919890000001',
      'latitude': 18.55,
      'longitude': 77.58,
      'rating': 4.5,
      'open': true,
      'verified': true,
      'imageUrl': 'https://example.com/shop.png',
      'createdAt': '2026-08-24T10:00:00Z',
      'distanceKm': 1.2,
    });
    expect(row, isA<Shop>());
    expect(row.id, 'biz-patil');
    expect(row.ownerId, 'user-1');
    expect(row.name, 'Patil Kirana');
    expect(row.isOpen, isTrue);
    expect(row.isVerified, isTrue);
    expect(row.rating, 4.5);
    expect(row.distanceKm, 1.2);
    expect(row.createdAt.toUtc().year, 2026);
  });

  test('Java shop JSON falls back when createdAt and flags are omitted', () {
    final row = JavaShopRepository.fromJson({
      'id': 'biz-hotel',
      'name': 'Hotel Sagar',
      'isOpen': false,
      'isVerified': false,
    });
    expect(row.id, 'biz-hotel');
    expect(row.name, 'Hotel Sagar');
    expect(row.isOpen, isFalse);
    expect(row.isVerified, isFalse);
    expect(row.createdAt.millisecondsSinceEpoch, 0);
  });
}
