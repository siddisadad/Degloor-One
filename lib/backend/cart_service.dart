import 'package:flutter/material.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';

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
        const SnackBar(content: Text('Please sign in to add items to cart')),
      );
      return;
    }

    try {
      // 1. Check for existing cart from different business
      final existingCarts = await cartsForUser(userId);

      if (existingCarts.isNotEmpty && existingCarts.first.businessId != businessId) {
        if (!context.mounted) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Replace Cart?'),
            content: const Text('Your cart contains items from another business. Would you like to clear it and add this item instead?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear and Add')),
            ],
          ),
        );

        if (confirm != true) return;

        // Clear existing cart
        await CartsTable().delete(matchingRows: (q) => q.eq('user_id', userId));
      }

      // 2. Get or Create Cart
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

      // 3. Add or Update Item
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

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $e'), backgroundColor: Colors.red),
      );
    }
  }

  static Future<List<CartsRow>> cartsForUser(String userId) {
    return CartsTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId).order('created_at', ascending: false),
    );
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
