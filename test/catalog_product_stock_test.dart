import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/catalog_product_stock.dart';

void main() {
  test('stock writes only serialize quantity', () {
    expect(
      const CatalogProductStock(12).toUpdateJson(),
      {'stock_quantity': 12},
    );
    expect(
      const CatalogProductStock(12).toUpdateJson().keys,
      isNot(contains('id')),
    );
    expect(
      const CatalogProductStock(12).toUpdateJson().containsKey('business_id'),
      isFalse,
    );
    expect(
      const CatalogProductStock(12).toUpdateJson().containsKey('created_at'),
      isFalse,
    );
  });

  test('stock parse stays off the widget and rejects junk', () {
    expect(CatalogProductStock.parse('8').quantity, 8);
    expect(
      () => CatalogProductStock.parse('plenty'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('valid stock'),
        ),
      ),
    );
    expect(
      () => const CatalogProductStock(-1).toUpdateJson(),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('valid stock'),
        ),
      ),
    );
  });
}
