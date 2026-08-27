import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/shared/shop_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('summarizeEvents aggregates shop actions and product interactions', () {
    final now = DateTime.now();
    final events = [
      ShopEvent(
        id: '1',
        businessId: 'biz-1',
        eventType: ShopEvents.profileView,
        createdAt: now,
      ),
      ShopEvent(
        id: '2',
        businessId: 'biz-1',
        eventType: ShopEvents.callClick,
        createdAt: now,
      ),
      ShopEvent(
        id: '3',
        businessId: 'biz-1',
        eventType: ShopEvents.productView,
        createdAt: now,
        metadata: {'product_id': 'prod-a'},
      ),
      ShopEvent(
        id: '4',
        businessId: 'biz-1',
        eventType: ShopEvents.addToCart,
        createdAt: now,
        metadata: {'product_id': 'prod-a'},
      ),
      ShopEvent(
        id: '5',
        businessId: 'biz-1',
        eventType: ShopEvents.productView,
        createdAt: now,
        metadata: {'product_id': 'prod-b'},
      ),
    ];

    final summary = ShopService.summarizeEvents(events);

    expect(summary.profileViews, 1);
    expect(summary.callClicks, 1);
    expect(summary.inquiries, 1); // Only call click here
    expect(summary.topProducts, hasLength(2));
    
    // prod-a has 2 interactions (view + add to cart)
    expect(summary.topProducts.first.key, 'prod-a');
    expect(summary.topProducts.first.value, 2);
    
    // prod-b has 1 interaction
    expect(summary.topProducts.last.key, 'prod-b');
    expect(summary.topProducts.last.value, 1);
  });

  test('summarizeEvents groups by day (MM/DD)', () {
    final events = [
      ShopEvent(
        id: '1',
        businessId: 'biz-1',
        eventType: ShopEvents.profileView,
        createdAt: DateTime(2026, 8, 10),
      ),
      ShopEvent(
        id: '2',
        businessId: 'biz-1',
        eventType: ShopEvents.profileView,
        createdAt: DateTime(2026, 8, 10),
      ),
      ShopEvent(
        id: '3',
        businessId: 'biz-1',
        eventType: ShopEvents.profileView,
        createdAt: DateTime(2026, 8, 11),
      ),
    ];

    final summary = ShopService.summarizeEvents(events);

    expect(summary.dailyCounts['08/10'], 2);
    expect(summary.dailyCounts['08/11'], 1);
  });
}
