import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('validateCartItems detects out of stock', () async {
    final items = [
      const CartLine(
        id: '1',
        cartId: 'c1',
        productId: ShowcaseCatalog.prodMilk,
        quantity: 100, // More than seeded 40
        product: JoinedProduct(id: ShowcaseCatalog.prodMilk, price: 60),
      ),
    ];

    final results = await CartService.validateCartItems(items);
    expect(results, hasLength(1));
    expect(results.first.status, CartValidationStatus.outOfStock);
    expect(results.first.message, contains('out of stock'));
  });

  test('validateCartItems detects price changes', () async {
    final items = [
      const CartLine(
        id: '1',
        cartId: 'c1',
        productId: ShowcaseCatalog.prodMilk,
        quantity: 1,
        product: JoinedProduct(id: ShowcaseCatalog.prodMilk, price: 50), // Seeded is 60
      ),
    ];

    final results = await CartService.validateCartItems(items);
    expect(results, hasLength(1));
    expect(results.first.status, CartValidationStatus.priceChanged);
    expect(results.first.newPrice, 60);
  });

  test('validateCartItems detects unavailable products', () async {
    final items = [
      const CartLine(
        id: '1',
        cartId: 'c1',
        productId: 'missing-id',
        quantity: 1,
        product: JoinedProduct(id: 'missing-id'),
      ),
    ];

    final results = await CartService.validateCartItems(items);
    expect(results, hasLength(1));
    expect(results.first.status, CartValidationStatus.unavailable);
  });
}
