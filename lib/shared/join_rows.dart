import 'package:degloor_one/shared/checkout_line_item.dart';

/// Normalize a PostgREST embedded join (`products(*)`, `users(...)`).
Map<String, dynamic>? asJoinMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is List && value.isNotEmpty) return asJoinMap(value.first);
  return null;
}

/// Display snapshot of a joined product. Checkout ignores [price].
class JoinedProduct {
  const JoinedProduct({
    required this.id,
    this.name,
    this.imageUrl,
    this.price,
  });

  final String id;
  final String? name;
  final String? imageUrl;
  final double? price;

  static JoinedProduct? fromJoin(dynamic value) {
    final map = asJoinMap(value);
    if (map == null || map.isEmpty) return null;
    final id = '${map['id'] ?? ''}'.trim();
    if (id.isEmpty) return null;
    return JoinedProduct(
      id: id,
      name: map['name']?.toString(),
      imageUrl: (map['image_url'] ?? map['imageUrl'])?.toString(),
      price: (map['price'] as num?)?.toDouble(),
    );
  }
}

/// Cart line with an optional product join. Payable price is not on this type.
class CartLine {
  const CartLine({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  final String id;
  final String cartId;
  final String productId;
  final int quantity;
  final JoinedProduct? product;

  factory CartLine.fromJoin(Map<String, dynamic> data) {
    final product = JoinedProduct.fromJoin(data['products']);
    final productId = '${data['product_id'] ?? product?.id ?? ''}'.trim();
    return CartLine(
      id: '${data['id'] ?? ''}',
      cartId: '${data['cart_id'] ?? ''}',
      productId: productId,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      product: product,
    );
  }

  /// Java `CartItemResponse`. Display [unitPrice] is not a payable amount.
  factory CartLine.fromJson(
    Map<String, dynamic> json, {
    required String cartId,
  }) {
    final productId = '${json['productId'] ?? ''}'.trim();
    return CartLine(
      id: '${json['id'] ?? productId}',
      cartId: cartId,
      productId: productId,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      product: productId.isEmpty
          ? null
          : JoinedProduct(
              id: productId,
              name: json['name'] as String?,
              imageUrl: json['imageUrl'] as String?,
              price: (json['unitPrice'] as num?)?.toDouble(),
            ),
    );
  }

  /// Checkout payload. Price stays off the wire.
  CheckoutLineItem toCheckoutItem() {
    return CheckoutLineItem(
      productId: productId,
      quantity: quantity,
    );
  }
}

/// Order line with an optional product join. [priceAtPurchase] is the
/// stored snapshot, not a client-supplied catalog price.
class OrderLine {
  const OrderLine({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    this.product,
  });

  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double priceAtPurchase;
  final JoinedProduct? product;

  factory OrderLine.fromJoin(Map<String, dynamic> data) {
    final product = JoinedProduct.fromJoin(data['products']);
    return OrderLine(
      id: '${data['id'] ?? ''}',
      orderId: '${data['order_id'] ?? ''}',
      productId: '${data['product_id'] ?? product?.id ?? ''}',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      priceAtPurchase: (data['price_at_purchase'] as num?)?.toDouble() ?? 0,
      product: product,
    );
  }

  /// Java `OrderItemResponse`. [priceAtPurchase] is the stored snapshot.
  factory OrderLine.fromJson(
    Map<String, dynamic> json, {
    required String orderId,
  }) {
    final productId = '${json['productId'] ?? ''}'.trim();
    return OrderLine(
      id: '${json['id'] ?? '$orderId-$productId'}',
      orderId: orderId,
      productId: productId,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      priceAtPurchase: (json['priceAtPurchase'] as num?)?.toDouble() ?? 0,
      product: productId.isEmpty ? null : JoinedProduct(id: productId),
    );
  }

  double get lineTotal => priceAtPurchase * quantity;
}
