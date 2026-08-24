import 'package:flutter/material.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/core/api/cart_api.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/checkout_line_item.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/rpc_row.dart';
import 'package:degloor_one/shared/shopping_cart.dart';
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

  factory CartAddResult.failure([Object? error]) => CartAddResult._(
        added: false,
        message: AppLogger.userFacingMessage(
          error,
          fallback: 'Unable to update the cart. Please try again.',
        ),
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
      AppLogger.event(
        'CART_ADD_FAILED',
        fields: {'user_id': userId, 'product_id': productId},
        error: e,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLogger.userFacingMessage(
              e,
              fallback: 'Unable to update the cart. Please try again.',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Data-only add so tests and UI share the same cart rules.
  /// Live path uses `add_to_cart()`; showcase stays local.
  static Future<CartAddResult> addProduct({
    required String userId,
    required String businessId,
    required String productId,
    int quantity = 1,
    bool replaceOtherBusiness = false,
  }) async {
    if (userId.isEmpty) return CartAddResult.signedOut;
    if (quantity < 1 || quantity > 99) {
      return CartAddResult.failure('CART_INVALID_QTY');
    }

    try {
      if (JavaApiConfig.enabled) {
        try {
          await CartApi.addItem(
            productId: productId,
            quantity: quantity,
            replaceOtherBusiness: replaceOtherBusiness,
          );
          return CartAddResult.success;
        } on JavaApiException catch (e) {
          if (e.code == 'CART_NEEDS_REPLACEMENT') {
            return CartAddResult.needsConfirm;
          }
          return CartAddResult.failure(e.message);
        }
      }
      if (!kUseShowcaseData) {
        return await _addProductLive(
          productId: productId,
          quantity: quantity,
          replaceOtherBusiness: replaceOtherBusiness,
        );
      }
      return await _addProductShowcase(
        userId: userId,
        businessId: businessId,
        productId: productId,
        quantity: quantity,
        replaceOtherBusiness: replaceOtherBusiness,
      );
    } catch (e) {
      AppLogger.event(
        'CART_ADD_FAILED',
        fields: {
          'user_id': userId,
          'product_id': productId,
          'business_id': businessId,
        },
        error: e,
      );
      return CartAddResult.failure(e);
    }
  }

  static Future<CartAddResult> _addProductLive({
    required String productId,
    required int quantity,
    required bool replaceOtherBusiness,
  }) async {
    final response = await SupaFlow.client.rpc(
      'add_to_cart',
      params: {
        'p_product_id': productId,
        'p_quantity': quantity,
        'p_replace_other_business': replaceOtherBusiness,
      },
    );
    final row = asRpcRow(response);
    if (row == null) {
      return CartAddResult.failure('CART_PRODUCT');
    }
    if (row['ok'] != true && row['code'] == 'needs_replacement') {
      return CartAddResult.needsConfirm;
    }
    if (row['ok'] == true) return CartAddResult.success;
    return CartAddResult.failure('CART_PRODUCT');
  }

  static Future<CartAddResult> _addProductShowcase({
    required String userId,
    required String businessId,
    required String productId,
    required int quantity,
    required bool replaceOtherBusiness,
  }) async {
    _assertShowcaseProduct(businessId: businessId, productId: productId);

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

    final nextQty = existingItems.isEmpty
        ? quantity
        : existingItems.first.quantity + quantity;
    _assertShowcaseStock(productId: productId, quantity: nextQty);

    if (existingItems.isNotEmpty) {
      await CartItemsTable().update(
        data: {'quantity': nextQty},
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
  }

  static Future<void> updateQuantity({
    required String itemId,
    required int quantity,
    String? userId,
  }) async {
    final uid = userId ?? currentUserUid;
    if (uid.isEmpty) {
      throw Exception('CART_UNAUTHORIZED');
    }
    if (JavaApiConfig.enabled) {
      await CartApi.updateItem(productId: itemId, quantity: quantity);
      return;
    }
    if (kUseShowcaseData) {
      _assertShowcaseCartItemOwner(itemId, uid);
      if (quantity <= 0) {
        await _removeShowcaseItem(itemId);
        return;
      }
      if (quantity > 99) {
        throw Exception('CART_INVALID_QTY');
      }
      final items = ShowcaseCatalog.query(
        'cart_items',
        ShowcaseQuery()..eq('id', itemId),
      );
      _assertShowcaseStock(
        productId: '${items.first['product_id']}',
        quantity: quantity,
      );
      await CartItemsTable().update(
        data: {'quantity': quantity},
        matchingRows: (q) => q.eq('id', itemId),
      );
      return;
    }
    await SupaFlow.client.rpc(
      'update_cart_quantity',
      params: {
        'p_item_id': itemId,
        'p_quantity': quantity,
      },
    );
  }

  static Future<void> removeItem({
    required String itemId,
    String? userId,
  }) {
    return updateQuantity(itemId: itemId, quantity: 0, userId: userId);
  }

  static Future<void> clearCart({String? userId}) async {
    final uid = userId ?? currentUserUid;
    if (uid.isEmpty) {
      throw Exception('CART_UNAUTHORIZED');
    }
    if (JavaApiConfig.enabled) {
      await CartApi.clear();
      return;
    }
    if (kUseShowcaseData) {
      await CartsTable().delete(matchingRows: (q) => q.eq('user_id', uid));
      return;
    }
    await SupaFlow.client.rpc('clear_cart');
  }

  static Future<Map<String, dynamic>?> _javaCartJson() async {
    final data = await CartApi.get();
    if ('${data['id'] ?? ''}'.isEmpty) return null;
    return data;
  }

  static Future<List<ShoppingCart>> cartsForUser(String userId) async {
    if (JavaApiConfig.enabled) {
      if (userId.isEmpty) return const [];
      final json = await _javaCartJson();
      if (json == null) return const [];
      final cart = ShoppingCart.fromJson(json, userId: userId);
      if (cart.id.isEmpty) return const [];
      return [cart];
    }
    final rows = await CartsTable().queryRows(
      queryFn: (q) =>
          q.eq('user_id', userId).order('created_at', ascending: false),
    );
    return rows.map(ShoppingCart.fromRow).toList();
  }

  static Future<List<CartLine>> itemsForCart(String cartId) async {
    if (JavaApiConfig.enabled) {
      if (cartId.isEmpty) return const [];
      final json = await _javaCartJson();
      if (json == null || '${json['id']}' != cartId) return const [];
      final items = json['items'];
      final rows = items is List ? items : const [];
      return [
        for (final row in rows.whereType<Map>())
          CartLine.fromJson(Map<String, dynamic>.from(row), cartId: cartId),
      ];
    }
    if (kUseShowcaseData) {
      return ShowcaseCatalog.cartItemsWithProducts(cartId)
          .map(CartLine.fromJoin)
          .toList();
    }
    final items = await SupaFlow.client
        .from('cart_items')
        .select('*, products(*)')
        .eq('cart_id', cartId);
    return List<Map<String, dynamic>>.from(items)
        .map(CartLine.fromJoin)
        .toList();
  }

  /// Display-only basket total. Checkout ignores these prices.
  static double subtotal(List<CartLine> items) {
    var total = 0.0;
    for (final item in items) {
      total += (item.product?.price ?? 0) * item.quantity;
    }
    return total;
  }

  /// Checkout payload. Prices stay off the wire; the server / catalog wins.
  static List<CheckoutLineItem> checkoutItems(List<CartLine> items) {
    return [for (final item in items) item.toCheckoutItem()];
  }

  static Future<int> getCartItemCount() async {
    final userId = currentUserUid;
    if (userId == '') return 0;
    if (JavaApiConfig.enabled) {
      final json = await _javaCartJson();
      if (json == null) return 0;
      final items = json['items'];
      final rows = items is List ? items : const [];
      var total = 0;
      for (final row in rows.whereType<Map>()) {
        total += (row['quantity'] as num?)?.toInt() ?? 0;
      }
      return total;
    }

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

  static void _assertShowcaseCartItemOwner(String itemId, String userId) {
    final items = ShowcaseCatalog.query(
      'cart_items',
      ShowcaseQuery()..eq('id', itemId),
    );
    if (items.isEmpty) {
      throw Exception('CART_NOT_FOUND');
    }
    final carts = ShowcaseCatalog.query(
      'carts',
      ShowcaseQuery()..eq('id', items.first['cart_id']),
    );
    if (carts.isEmpty || carts.first['user_id'] != userId) {
      throw Exception('CART_UNAUTHORIZED');
    }
  }

  static Future<void> _removeShowcaseItem(String itemId) async {
    final items = ShowcaseCatalog.query(
      'cart_items',
      ShowcaseQuery()..eq('id', itemId),
    );
    await CartItemsTable().delete(matchingRows: (q) => q.eq('id', itemId));
    if (items.isEmpty) return;
    final cartId = '${items.first['cart_id']}';
    final remaining = ShowcaseCatalog.query(
      'cart_items',
      ShowcaseQuery()..eq('cart_id', cartId),
    );
    if (remaining.isEmpty) {
      await CartsTable().delete(matchingRows: (q) => q.eq('id', cartId));
    }
  }

  static void _assertShowcaseProduct({
    required String businessId,
    required String productId,
  }) {
    final products = ShowcaseCatalog.query(
      'products',
      ShowcaseQuery()..eq('id', productId),
    );
    if (products.isEmpty || products.first['business_id'] != businessId) {
      throw Exception('CART_PRODUCT');
    }
    if (products.first['is_available'] == false) {
      throw Exception('CART_UNAVAILABLE');
    }
  }

  static void _assertShowcaseStock({
    required String productId,
    required int quantity,
  }) {
    final products = ShowcaseCatalog.query(
      'products',
      ShowcaseQuery()..eq('id', productId),
    );
    if (products.isEmpty) {
      throw Exception('CART_PRODUCT');
    }
    if (products.first['track_inventory'] != true) return;
    final stock = (products.first['stock_quantity'] as num?)?.toInt() ?? 0;
    if (stock < quantity) {
      throw Exception('CART_STOCK');
    }
  }
}
