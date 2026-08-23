import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/shop_hours.dart';

void main() {
  test('hours upsert JSON uses TIME strings and the owned shop id', () {
    final hours = ShopHours(
      id: 'h-1',
      businessId: 'other-shop',
      dayOfWeek: 0,
      openTime: DateTime(1970, 1, 1, 9, 30),
      closeTime: DateTime(1970, 1, 1, 18),
      isClosed: false,
    );
    expect(hours.toUpsertJson(businessId: 'biz-owned'), {
      'id': 'h-1',
      'business_id': 'biz-owned',
      'day_of_week': 0,
      'open_time': '09:30:00',
      'close_time': '18:00:00',
      'is_closed': false,
    });
    expect(
      hours.toUpsertJson(businessId: 'biz-owned').keys,
      ['id', 'business_id', 'day_of_week', 'open_time', 'close_time', 'is_closed'],
    );
  });

  test('missing open time stays the default TIME string', () {
    expect(ShopHours.sqlTime(null), '09:00:00');
    expect(
      ShopHours(dayOfWeek: 1).toUpsertJson(businessId: 'biz-1')['open_time'],
      '09:00:00',
    );
  });
}
