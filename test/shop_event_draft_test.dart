import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/shop_event_draft.dart';

void main() {
  test('event drafts only serialize submit fields', () {
    const draft = ShopEventDraft(
      businessId: 'biz-1',
      eventType: 'PRODUCT_VIEW',
      userId: 'user-1',
      metadata: {'product_id': 'prod-x'},
    );
    expect(draft.toInsertJson(), {
      'business_id': 'biz-1',
      'event_type': 'PRODUCT_VIEW',
      'user_id': 'user-1',
      'metadata': {'product_id': 'prod-x'},
    });
    expect(
      draft.toInsertJson().keys,
      ['business_id', 'event_type', 'user_id', 'metadata'],
    );
  });

  test('empty user id and missing metadata stay off the insert payload', () {
    expect(
      const ShopEventDraft(
        businessId: 'biz-1',
        eventType: 'PROFILE_VIEW',
        userId: '',
      ).toInsertJson(),
      {
        'business_id': 'biz-1',
        'event_type': 'PROFILE_VIEW',
      },
    );
  });
}
