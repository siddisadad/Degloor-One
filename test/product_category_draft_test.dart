import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/product_category_draft.dart';

void main() {
  test('category drafts only serialize business id and name', () {
    const draft = ProductCategoryDraft(
      businessId: 'biz-1',
      name: 'Spices',
    );
    expect(draft.toInsertJson(), {
      'business_id': 'biz-1',
      'name': 'Spices',
    });
    expect(draft.toInsertJson().keys, ['business_id', 'name']);
    expect(draft.toInsertJson().containsKey('id'), isFalse);
    expect(draft.toInsertJson().containsKey('created_at'), isFalse);
  });
}
