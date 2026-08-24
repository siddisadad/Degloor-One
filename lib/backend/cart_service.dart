import 'package:flutter/material.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/data/repositories/cart_repository.dart';
import 'package:degloor_one/shared/checkout_line_item.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/shopping_cart.dart';

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
  CartService({required CartRepository repository}) : _repository = repository;

  final CartRepository _repository;

  static CartService? _instance;

  static CartService get instance {
    final bound = _instance;
    if (bound == null) {
      throw StateError('CartService is not bound.');
    }
    return bound;
  }

  /// Called from the composition root with a concrete repository.
  static void bind(CartRepository repository) {
    _instance = CartService(repository: repository);
  }

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
      await instance._repository.addProduct(
        userId: userId,
        businessId: businessId,
        productId: productId,
        quantity: quantity,
        replaceOtherBusiness: replaceOtherBusiness,
      );
      return CartAddResult.success;
    } on CartNeedsReplacement {
      return CartAddResult.needsConfirm;
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

  static Future<void> updateQuantity({
    required String itemId,
    required int quantity,
    String? userId,
  }) async {
    final uid = userId ?? currentUserUid;
    if (uid.isEmpty) {
      throw Exception('CART_UNAUTHORIZED');
    }
    await instance._repository.updateQuantity(
      itemId: itemId,
      quantity: quantity,
      userId: uid,
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
    await instance._repository.clearCart(userId: uid);
  }

  static Future<List<ShoppingCart>> cartsForUser(String userId) {
    if (userId.isEmpty) return Future.value(const []);
    return instance._repository.cartsForUser(userId);
  }

  static Future<List<CartLine>> itemsForCart(String cartId) {
    if (cartId.isEmpty) return Future.value(const []);
    return instance._repository.itemsForCart(cartId);
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
    return instance._repository.itemCount(userId);
  }
}
