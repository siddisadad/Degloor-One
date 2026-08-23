import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/listing_complaint_draft.dart';

void main() {
  test('complaint drafts only serialize submit fields', () {
    const draft = ListingComplaintDraft(
      userId: 'user-1',
      businessId: 'biz-1',
      subject: 'Closed early',
      description: 'Shop closed before advertised hours.',
    );
    expect(draft.toInsertJson(), {
      'user_id': 'user-1',
      'business_id': 'biz-1',
      'subject': 'Closed early',
      'description': 'Shop closed before advertised hours.',
      'status': ListingComplaintDraft.pending,
    });
    expect(
      draft.toInsertJson().keys,
      ['user_id', 'business_id', 'subject', 'description', 'status'],
    );
  });

  test('empty order id stays off the insert payload', () {
    const draft = ListingComplaintDraft(
      userId: 'user-1',
      businessId: 'biz-1',
      subject: 'Closed early',
      description: 'Hours were wrong.',
      orderId: '',
    );
    expect(draft.toInsertJson().containsKey('order_id'), isFalse);
    expect(
      const ListingComplaintDraft(
        userId: 'user-1',
        businessId: 'biz-1',
        subject: 'Closed early',
        description: 'Hours were wrong.',
        orderId: 'order-1',
      ).toInsertJson()['order_id'],
      'order-1',
    );
  });
}
