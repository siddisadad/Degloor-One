import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/catalog_product_draft.dart';

void main() {
  test('product drafts only serialize insert fields', () {
    const draft = CatalogProductDraft(
      name: 'Turmeric',
      price: 25,
      imageUrl: 'https://img',
      stockQuantity: 4,
      trackInventory: true,
    );
    expect(
      draft.toInsertJson(businessId: 'biz-1', categoryId: 'pcat-1'),
      {
        'business_id': 'biz-1',
        'category_id': 'pcat-1',
        'name': 'Turmeric',
        'price': 25,
        'image_url': 'https://img',
        'is_available': true,
        'stock_quantity': 4,
        'track_inventory': true,
      },
    );
    expect(
      draft.toInsertJson(businessId: 'biz-1', categoryId: 'pcat-1').keys,
      isNot(contains('id')),
    );
    expect(
      draft.toInsertJson(businessId: 'biz-1', categoryId: 'pcat-1').containsKey(
        'created_at',
      ),
      isFalse,
    );
  });

  test('fromForm parses price and stock off the widget', () {
    final draft = CatalogProductDraft.fromForm(
      name: 'Curd',
      priceText: '40',
      stockText: '6',
      categoryName: 'Dairy',
    );
    expect(draft.price, 40);
    expect(draft.stockQuantity, 6);
    expect(draft.categoryName, 'Dairy');
    expect(
      () => CatalogProductDraft.fromForm(name: 'Curd', priceText: 'free'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('valid price'),
        ),
      ),
    );
  });

  test('update payload stays off id and business id', () {
    expect(
      const CatalogProductDraft(name: 'Milk', price: 30).toUpdateJson().keys,
      ['name', 'price', 'stock_quantity', 'track_inventory', 'image_url'],
    );
  });
}
