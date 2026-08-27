/// One shop basket. Screens use this instead of a table row.
/// Line items stay on [CartLine]. Checkout ignores client prices.
class ShoppingCart {
  const ShoppingCart({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String businessId;
  final DateTime createdAt;

  /// Java `CartResponse`. Empty carts omit [id].
  factory ShoppingCart.fromJson(
    Map<String, dynamic> json, {
    required String userId,
  }) {
    return ShoppingCart(
      id: '${json['id'] ?? ''}',
      userId: userId,
      businessId: '${json['businessId'] ?? ''}',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
