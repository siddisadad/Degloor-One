import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/data/datasources/supabase_cart_maps.dart';
import 'package:degloor_one/data/repositories/cart_repository.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/rpc_row.dart';
import 'package:degloor_one/shared/shopping_cart.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

/// Showcase or live table access for carts and cart lines.
class SupabaseCartRepository implements CartRepository {
  @override
  Future<void> addProduct({
    required String userId,
    required String businessId,
    required String productId,
    int quantity = 1,
    bool replaceOtherBusiness = false,
  }) {
    if (kUseShowcaseData) {
      return _addProductShowcase(
        userId: userId,
        businessId: businessId,
        productId: productId,
        quantity: quantity,
        replaceOtherBusiness: replaceOtherBusiness,
      );
    }
    return _addProductLive(
      productId: productId,
      quantity: quantity,
      replaceOtherBusiness: replaceOtherBusiness,
    );
  }

  Future<void> _addProductLive({
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
      throw Exception('CART_PRODUCT');
    }
    if (row['ok'] != true && row['code'] == 'needs_replacement') {
      throw CartNeedsReplacement();
    }
    if (row['ok'] == true) return;
    throw Exception('CART_PRODUCT');
  }

  Future<void> _addProductShowcase({
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
      if (!replaceOtherBusiness) throw CartNeedsReplacement();
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
  }

  @override
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
    required String userId,
  }) async {
    if (kUseShowcaseData) {
      _assertShowcaseCartItemOwner(itemId, userId);
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

  @override
  Future<void> clearCart({required String userId}) async {
    if (kUseShowcaseData) {
      await CartsTable().delete(matchingRows: (q) => q.eq('user_id', userId));
      return;
    }
    await SupaFlow.client.rpc('clear_cart');
  }

  @override
  Future<List<ShoppingCart>> cartsForUser(String userId) async {
    final rows = await CartsTable().queryRows(
      queryFn: (q) =>
          q.eq('user_id', userId).order('created_at', ascending: false),
    );
    return rows.map(shoppingCartFromRow).toList();
  }

  @override
  Future<List<CartLine>> itemsForCart(String cartId) async {
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

  @override
  Future<int> itemCount(String userId) async {
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
