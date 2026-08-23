import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/checkout_line_item.dart';
import 'package:degloor_one/shared/join_rows.dart';

void main() {
  test('checkout line items only serialize product id and quantity', () {
    const item = CheckoutLineItem(productId: 'prod-x', quantity: 3);
    expect(item.toRpcJson(), {'product_id': 'prod-x', 'quantity': 3});
    expect(item.toRpcJson().keys, ['product_id', 'quantity']);
  });

  test('CartLine checkout payload cannot carry a client price', () {
    final line = CartLine.fromJoin({
      'product_id': 'prod-x',
      'quantity': 2,
      'products': {'id': 'prod-x', 'price': 1.0},
    });
    expect(line.toCheckoutItem(), isA<CheckoutLineItem>());
    expect(line.toCheckoutItem().productId, 'prod-x');
    expect(line.toCheckoutItem().quantity, 2);
    expect(line.toCheckoutItem().toRpcJson().containsKey('price'), isFalse);
  });
}
