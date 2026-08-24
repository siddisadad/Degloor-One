import 'package:degloor_one/backend/supabase/database/tables/carts_table.dart';

/// One shop basket. Screens use this instead of [CartsRow].
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

  factory ShoppingCart.fromRow(CartsRow row) {
    return ShoppingCart(
      id: row.id,
      userId: row.userId,
      businessId: row.businessId,
      createdAt: row.createdAt,
    );
  }

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
