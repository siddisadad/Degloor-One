import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/join_rows.dart';

void main() {
  test('CartLine.fromJoin reads the product join and omits price on checkout',
      () {
    final line = CartLine.fromJoin({
      'id': 'ci-1',
      'cart_id': 'cart-1',
      'quantity': 2,
      'products': {
        'id': 'prod-x',
        'name': 'Rice',
        'price': 1.0,
        'image_url': 'https://example.com/rice.png',
      },
    });
    expect(line.productId, 'prod-x');
    expect(line.product?.name, 'Rice');
    expect(line.product?.price, 1.0);
    expect(line.product?.imageUrl, 'https://example.com/rice.png');
    final checkout = line.toCheckoutItem();
    expect(checkout.productId, 'prod-x');
    expect(checkout.quantity, 2);
    expect(checkout.toRpcJson(), {'product_id': 'prod-x', 'quantity': 2});
    expect(checkout.toRpcJson().containsKey('price'), isFalse);
  });

  test('empty or missing product join is null', () {
    expect(JoinedProduct.fromJoin(<String, dynamic>{}), isNull);
    expect(JoinedProduct.fromJoin(null), isNull);
    expect(
      OrderLine.fromJoin({
        'id': 'oi-1',
        'order_id': 'o-1',
        'product_id': 'prod-x',
        'quantity': 1,
        'price_at_purchase': 120,
        'products': <String, dynamic>{},
      }).product,
      isNull,
    );
  });

  test('OrderLine uses stored purchase price, not the joined catalog price',
      () {
    final line = OrderLine.fromJoin({
      'id': 'oi-1',
      'order_id': 'o-1',
      'product_id': 'prod-x',
      'quantity': 2,
      'price_at_purchase': 120,
      'products': {'id': 'prod-x', 'name': 'Rice', 'price': 1.0},
    });
    expect(line.lineTotal, 240);
    expect(line.product?.price, 1.0);
  });

  test('OrderLine.fromJson maps Java product name and image', () {
    final line = OrderLine.fromJson({
      'productId': 'prod-rice',
      'quantity': 2,
      'priceAtPurchase': 120,
      'name': 'Rice (1kg)',
      'imageUrl': 'https://example.com/rice.png',
    }, orderId: 'o-1');
    expect(line.productId, 'prod-rice');
    expect(line.product?.name, 'Rice (1kg)');
    expect(line.product?.imageUrl, 'https://example.com/rice.png');
    expect(line.product?.price, isNull);
    expect(line.lineTotal, 240);

    final bare = OrderLine.fromJson({
      'productId': 'prod-tea',
      'quantity': 1,
      'priceAtPurchase': 20,
    }, orderId: 'o-1');
    expect(bare.product?.name, isNull);
    expect(bare.product?.imageUrl, isNull);
  });
}
