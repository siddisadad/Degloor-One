/// One product a customer wants to buy. Price and status stay off this
/// type so checkout cannot send a client total.
class CheckoutLineItem {
  const CheckoutLineItem({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final int quantity;

  /// Supabase RPC / showcase input only. Never includes price.
  Map<String, dynamic> toRpcJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }
}
