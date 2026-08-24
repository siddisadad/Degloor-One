import 'package:degloor_one/data/datasources/java_shop_repository.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/shop_hours.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Java nested hours map to ShopHours', () {
    final hours = JavaShopRepository.hoursFromJson({
      'id': 'biz-patil',
      'hours': [
        {
          'dayOfWeek': 1,
          'openTime': '09:00:00',
          'closeTime': '18:00:00',
          'closed': false,
        },
        {
          'dayOfWeek': 0,
          'openTime': '10:00',
          'closeTime': '14:00',
          'closed': true,
        },
      ],
    });
    expect(hours, hasLength(2));
    expect(hours.first.businessId, 'biz-patil');
    expect(hours.first.dayOfWeek, 1);
    expect(hours.first.openTime?.hour, 9);
    expect(hours.first.closeTime?.hour, 18);
    expect(hours.first.isClosed, isFalse);
    expect(hours.last.isClosed, isTrue);
  });

  test('Java product JSON maps to CatalogProduct', () {
    final product = CatalogProduct.fromJson({
      'id': 'prod-1',
      'businessId': 'biz-patil',
      'categoryId': 'cat-1',
      'name': 'Milk',
      'price': 42,
      'available': true,
      'stockQuantity': 8,
      'trackInventory': true,
    });
    expect(product.id, 'prod-1');
    expect(product.businessId, 'biz-patil');
    expect(product.name, 'Milk');
    expect(product.price, 42);
    expect(product.isAvailable, isTrue);
    expect(product.stockQuantity, 8);
    expect(product.createdAt.millisecondsSinceEpoch, 0);
  });

  test('Java review and complaint JSON map to domain types', () {
    final review = ShopReview.fromJson({
      'id': 'rev-1',
      'userId': 'user-1',
      'businessId': 'biz-patil',
      'rating': 5,
      'comment': 'Fresh milk',
      'createdAt': '2026-08-24T10:00:00Z',
    });
    expect(review.id, 'rev-1');
    expect(review.userId, 'user-1');
    expect(review.rating, 5);
    expect(review.comment, 'Fresh milk');

    final complaint = ListingComplaint.fromJson({
      'id': 'cmp-1',
      'userId': 'user-1',
      'businessId': 'biz-patil',
      'subject': 'Missing item',
      'description': 'No sweet in the thali',
      'status': 'pending',
      'createdAt': '2026-08-24T10:00:00Z',
    });
    expect(complaint.id, 'cmp-1');
    expect(complaint.subject, 'Missing item');
    expect(complaint.status, 'pending');
  });
}
