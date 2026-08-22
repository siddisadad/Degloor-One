import 'package:flutter/material.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class CartAddResult {
  const CartAddResult._({
    required this.added,
    this.needsReplacement = false,
    this.message,
  });

  final bool added;
  final bool needsReplacement;
  final String? message;

  static const signedOut = CartAddResult._(
    added: false,
    message: 'Please sign in to add items to cart',
  );

  static const needsConfirm = CartAddResult._(
    added: false,
    needsReplacement: true,
  );

  static const success = CartAddResult._(
    added: true,
    message: 'Added to cart',
  );

  factory CartAddResult.failure(Object error) => CartAddResult._(
        added: false,
        message: 'Error adding to cart: $error',
      );
}

class CartService {
  static Future<void> addToCart({
    required BuildContext context,
    required String businessId,
    required String productId,
    int quantity = 1,
  }) async {
    final userId = currentUserUid;
    if (userId == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(CartAddResult.signedOut.message!)),
      );
      return;
    }

    try {
      var result = await addProduct(
        userId: userId,
        businessId: businessId,
        productId: productId,
        quantity: quantity,
      );

      if (result.needsReplacement) {
        if (!context.mounted) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Replace Cart?'),
            content: const Text(
              'Your cart contains items from another business. Would you like to clear it and add this item instead?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Clear and Add'),
              ),
            ],
          ),
        );

        if (confirm != true) return;
        result = await addProduct(
          userId: userId,
          businessId: businessId,
          productId: productId,
          quantity: quantity,
          replaceOtherBusiness: true,
        );
      }

      if (!context.mounted) return;
      if (result.added) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Added to cart'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Data-only add so tests and UI share the same cart rules.
  static Future<CartAddResult> addProduct({
    required String userId,
    required String businessId,
    required String productId,
    int quantity = 1,
    bool replaceOtherBusiness = false,
  }) async {
    if (userId.isEmpty) return CartAddResult.signedOut;

    try {
      final existingCarts = await cartsForUser(userId);

      if (existingCarts.isNotEmpty &&
          existingCarts.first.businessId != businessId) {
        if (!replaceOtherBusiness) return CartAddResult.needsConfirm;
        await CartsTable().delete(matchingRows: (q) => q.eq('user_id', userId));
      }

      String cartId;
      final currentCart = await CartsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).eq('business_id', businessId),
      );

      if (currentCart.isEmpty) {
        final newCart = await CartsTable().insert({
          'user_id': userId,
          'business_id': businessId,
          'created_at': DateTime.now().toIso8601String(),
        });
        cartId = newCart.id;
      } else {
        cartId = currentCart.first.id;
      }

      final existingItems = await CartItemsTable().queryRows(
        queryFn: (q) => q.eq('cart_id', cartId).eq('product_id', productId),
      );

      if (existingItems.isNotEmpty) {
        await CartItemsTable().update(
          data: {'quantity': existingItems.first.quantity + quantity},
          matchingRows: (q) => q.eq('id', existingItems.first.id),
        );
      } else {
        await CartItemsTable().insert({
          'cart_id': cartId,
          'product_id': productId,
          'quantity': quantity,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return CartAddResult.success;
    } catch (e) {
      return CartAddResult.failure(e);
    }
  }

  static Future<List<CartsRow>> cartsForUser(String userId) {
    return CartsTable().queryRows(
      queryFn: (q) =>
          q.eq('user_id', userId).order('created_at', ascending: false),
    );
  }

  static Future<List<Map<String, dynamic>>> itemsForCart(String cartId) async {
    if (kUseShowcaseData) {
      return ShowcaseCatalog.cartItemsWithProducts(cartId);
    }
    final items = await SupaFlow.client
        .from('cart_items')
        .select('*, products(*)')
        .eq('cart_id', cartId);
    return List<Map<String, dynamic>>.from(items);
  }

  static Future<int> getCartItemCount() async {
    final userId = currentUserUid;
    if (userId == '') return 0;

    final carts = await cartsForUser(userId);
    if (carts.isEmpty) return 0;

    var total = 0;
    for (final cart in carts) {
      final items = await CartItemsTable().queryRows(
        queryFn: (q) => q.eq('cart_id', cart.id),
      );
      total += items.fold<int>(0, (sum, item) => sum + item.quantity);
    }
    return total;
  }
}
