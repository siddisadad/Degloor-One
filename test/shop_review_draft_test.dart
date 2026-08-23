import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/shop_review_draft.dart';

void main() {
  test('review drafts only serialize submit fields', () {
    const draft = ShopReviewDraft(
      userId: 'user-1',
      businessId: 'biz-1',
      rating: 4,
      comment: 'Good shop',
    );
    expect(draft.toInsertJson(), {
      'user_id': 'user-1',
      'business_id': 'biz-1',
      'rating': 4,
      'comment': 'Good shop',
    });
    expect(
      draft.toInsertJson().keys,
      ['user_id', 'business_id', 'rating', 'comment'],
    );
  });

  test('empty order id stays off the insert payload', () {
    const draft = ShopReviewDraft(
      userId: 'user-1',
      businessId: 'biz-1',
      rating: 5,
      orderId: '',
    );
    expect(draft.toInsertJson().containsKey('order_id'), isFalse);
    expect(
      const ShopReviewDraft(
        userId: 'user-1',
        businessId: 'biz-1',
        rating: 5,
        orderId: 'order-1',
      ).toInsertJson()['order_id'],
      'order-1',
    );
  });
}
