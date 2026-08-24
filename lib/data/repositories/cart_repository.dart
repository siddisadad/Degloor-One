import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/shopping_cart.dart';

/// Another shop already owns the cart. The caller may retry with replacement.
class CartNeedsReplacement implements Exception {
  @override
  String toString() => 'CART_NEEDS_REPLACEMENT';
}

/// Data access for the signed-in user's cart. Screens go through [CartService].
/// Concrete implementations map table rows or API JSON.
abstract class CartRepository {
  Future<void> addProduct({
    required String userId,
    required String businessId,
    required String productId,
    int quantity = 1,
    bool replaceOtherBusiness = false,
  });

  /// [itemId] is the cart line id on showcase/Supabase and the product id on Java.
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
    required String userId,
  });

  Future<void> clearCart({required String userId});

  Future<List<ShoppingCart>> cartsForUser(String userId);

  Future<List<CartLine>> itemsForCart(String cartId);

  Future<int> itemCount(String userId);
}
