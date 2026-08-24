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
      [
        'id',
        'business_id',
        'day_of_week',
        'open_time',
        'close_time',
        'is_closed'
      ],
    );
  });

  test('missing open time stays the default TIME string', () {
    expect(ShopHours.sqlTime(null), '09:00:00');
    expect(
      ShopHours(dayOfWeek: 1).toUpsertJson(businessId: 'biz-1')['open_time'],
      '09:00:00',
    );
  });

  test('isOpenNow handles same-day, overnight, and closed windows', () {
    ShopHours window({
      required int day,
      required int openHour,
      required int closeHour,
      bool closed = false,
    }) {
      return ShopHours(
        dayOfWeek: day,
        openTime: DateTime(1970, 1, 1, openHour),
        closeTime: DateTime(1970, 1, 1, closeHour),
        isClosed: closed,
      );
    }

    final sundayMorning = DateTime(2026, 8, 23, 10);
    final sundayLate = DateTime(2026, 8, 23, 22);
    final sundayOvernight = DateTime(2026, 8, 23, 1);
    expect(
      ShopHours.isOpenNow(
        [window(day: 0, openHour: 9, closeHour: 18)],
        now: sundayMorning,
      ),
      isTrue,
    );
    expect(
      ShopHours.isOpenNow(
        [window(day: 0, openHour: 9, closeHour: 18)],
        now: sundayLate,
      ),
      isFalse,
    );
    expect(ShopHours.isOpenNow(const [], now: sundayMorning), isFalse);
    expect(
      ShopHours.isOpenNow(
        [window(day: 0, openHour: 9, closeHour: 18, closed: true)],
        now: sundayMorning,
      ),
      isFalse,
    );
    expect(
      ShopHours.isOpenNow(
        [window(day: 0, openHour: 22, closeHour: 2)],
        now: sundayLate,
      ),
      isTrue,
    );
    expect(
      ShopHours.isOpenNow(
        [window(day: 0, openHour: 22, closeHour: 2)],
        now: sundayOvernight,
      ),
      isTrue,
    );
    expect(
      ShopHours.isOpenNow(
        [window(day: 0, openHour: 22, closeHour: 2)],
        now: sundayMorning,
      ),
      isFalse,
    );
  });
}
