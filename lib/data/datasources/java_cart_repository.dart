import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/core/api/cart_api.dart';
import 'package:degloor_one/data/repositories/cart_repository.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/shopping_cart.dart';

/// Cart access through the Java API. Table rows stay on the server.
class JavaCartRepository implements CartRepository {
  Future<Map<String, dynamic>?> _cartJson() async {
    final data = await CartApi.get();
    if ('${data['id'] ?? ''}'.isEmpty) return null;
    return data;
  }

  static List<CartLine> linesFromJson(
    Map<String, dynamic> json, {
    required String cartId,
  }) {
    final items = json['items'];
    final rows = items is List ? items : const [];
    return [
      for (final row in rows.whereType<Map>())
        CartLine.fromJson(Map<String, dynamic>.from(row), cartId: cartId),
    ];
  }

  static int quantityFromJson(Map<String, dynamic> json) {
    final items = json['items'];
    final rows = items is List ? items : const [];
    var total = 0;
    for (final row in rows.whereType<Map>()) {
      total += (row['quantity'] as num?)?.toInt() ?? 0;
    }
    return total;
  }

  @override
  Future<void> addProduct({
    required String userId,
    required String businessId,
    required String productId,
    int quantity = 1,
    bool replaceOtherBusiness = false,
  }) async {
    if (userId.isEmpty) {
      throw Exception('CART_UNAUTHORIZED');
    }
    try {
      await CartApi.addItem(
        productId: productId,
        quantity: quantity,
        replaceOtherBusiness: replaceOtherBusiness,
      );
    } on JavaApiException catch (error) {
      if (error.code == 'CART_NEEDS_REPLACEMENT') {
        throw CartNeedsReplacement();
      }
      rethrow;
    }
  }

  @override
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
    required String userId,
  }) {
    return CartApi.updateItem(productId: itemId, quantity: quantity);
  }

  @override
  Future<void> clearCart({required String userId}) {
    return CartApi.clear();
  }

  @override
  Future<List<ShoppingCart>> cartsForUser(String userId) async {
    if (userId.isEmpty) return const [];
    final json = await _cartJson();
    if (json == null) return const [];
    final cart = ShoppingCart.fromJson(json, userId: userId);
    if (cart.id.isEmpty) return const [];
    return [cart];
  }

  @override
  Future<List<CartLine>> itemsForCart(String cartId) async {
    if (cartId.isEmpty) return const [];
    final json = await _cartJson();
    if (json == null || '${json['id']}' != cartId) return const [];
    return linesFromJson(json, cartId: cartId);
  }

  @override
  Future<int> itemCount(String userId) async {
    if (userId.isEmpty) return 0;
    final json = await _cartJson();
    if (json == null) return 0;
    return quantityFromJson(json);
  }
}
