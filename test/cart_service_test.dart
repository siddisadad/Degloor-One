import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/checkout_line_item.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/shopping_cart.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(() {
    ShowcaseCatalog.reset();
    installGuestSession();
  });

  test('itemsForCart joins showcase products', () async {
    expect(kUseShowcaseData, isTrue);
    final items = await CartService.itemsForCart(ShowcaseCatalog.cartGuest);
    expect(items, isNotEmpty);
    expect(items.first.product, isA<JoinedProduct>());
    expect(
      items.any((item) => item.productId == ShowcaseCatalog.prodRice),
      isTrue,
    );
  });

  test('addProduct increments quantity on the guest cart', () async {
    final before = await CartService.itemsForCart(ShowcaseCatalog.cartGuest);
    final riceBefore = before.firstWhere(
      (item) => item.productId == ShowcaseCatalog.prodRice,
    );

    final result = await CartService.addProduct(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
      productId: ShowcaseCatalog.prodRice,
    );
    expect(result.added, isTrue);

    final after = await CartService.itemsForCart(ShowcaseCatalog.cartGuest);
    final riceAfter = after.firstWhere(
      (item) => item.productId == ShowcaseCatalog.prodRice,
    );
    expect(riceAfter.quantity, riceBefore.quantity + 1);
  });

  test('addProduct from another shop asks for replacement', () async {
    final result = await CartService.addProduct(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizHotel,
      productId: ShowcaseCatalog.prodThali,
    );
    expect(result.needsReplacement, isTrue);
    expect(result.added, isFalse);

    final items = await CartService.itemsForCart(ShowcaseCatalog.cartGuest);
    expect(
      items.any((item) => item.productId == ShowcaseCatalog.prodThali),
      isFalse,
    );
  });

  test('addProduct can replace another shop cart', () async {
    final result = await CartService.addProduct(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizHotel,
      productId: ShowcaseCatalog.prodThali,
      replaceOtherBusiness: true,
    );
    expect(result.added, isTrue);

    final carts = await CartService.cartsForUser(GuestAuthUser.guestUid);
    expect(carts, isNotEmpty);
    expect(carts, everyElement(isA<ShoppingCart>()));
    expect(carts, isNot(anyElement(isA<CartsRow>())));
    expect(carts.first.businessId, ShowcaseCatalog.bizHotel);
    final items = await CartService.itemsForCart(carts.first.id);
    expect(
      items.any((item) => item.productId == ShowcaseCatalog.prodThali),
      isTrue,
    );
  });

  test('updateQuantity changes an owned line and rejects another user',
      () async {
    await CartService.updateQuantity(
      itemId: 'ci-rice',
      quantity: 3,
      userId: GuestAuthUser.guestUid,
    );
    final items = await CartService.itemsForCart(ShowcaseCatalog.cartGuest);
    final rice = items.firstWhere(
      (item) => item.productId == ShowcaseCatalog.prodRice,
    );
    expect(rice.quantity, 3);

    await expectLater(
      CartService.updateQuantity(
        itemId: 'ci-rice',
        quantity: 4,
        userId: ShowcaseCatalog.customer2,
      ),
      throwsA(
        predicate(
          (error) => error.toString().contains('CART_UNAUTHORIZED'),
        ),
      ),
    );
  });

  test('removeItem and clearCart empty the guest basket', () async {
    await CartService.removeItem(
      itemId: 'ci-milk',
      userId: GuestAuthUser.guestUid,
    );
    final items = await CartService.itemsForCart(ShowcaseCatalog.cartGuest);
    expect(
      items.any((item) => item.id == 'ci-milk'),
      isFalse,
    );

    await CartService.clearCart(userId: GuestAuthUser.guestUid);
    final carts = await CartService.cartsForUser(GuestAuthUser.guestUid);
    expect(carts, isA<List<ShoppingCart>>());
    expect(carts, isEmpty);
  });

  test('subtotal is display-only and checkoutItems omit price', () async {
    final items = await CartService.itemsForCart(ShowcaseCatalog.cartGuest);
    expect(CartService.subtotal(items), 240);
    final checkout = CartService.checkoutItems(items);
    expect(checkout, everyElement(isA<CheckoutLineItem>()));
    expect(
      checkout.every((item) => !item.toRpcJson().containsKey('price')),
      isTrue,
    );
    expect(
      checkout.map((item) => item.productId),
      containsAll([ShowcaseCatalog.prodMilk, ShowcaseCatalog.prodRice]),
    );
    expect(
      CartService.checkoutItems([
        CartLine.fromJoin({
          'products': {'id': 'prod-x', 'price': 1},
          'quantity': 2,
        }),
      ]).single.toRpcJson(),
      {'product_id': 'prod-x', 'quantity': 2},
    );
  });

  test('invalid quantity is rejected without writing', () async {
    final result = await CartService.addProduct(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
      productId: ShowcaseCatalog.prodRice,
      quantity: 0,
    );
    expect(result.added, isFalse);
    expect(result.message, 'Please choose a valid quantity.');
  });

  test('Java cart JSON maps to ShoppingCart and CartLine', () {
    final cart = ShoppingCart.fromJson({
      'id': 'cart-1',
      'businessId': 'biz-patil',
      'businessName': 'Patil Kirana',
      'subtotal': 240,
    }, userId: GuestAuthUser.guestUid);
    expect(cart, isA<ShoppingCart>());
    expect(cart.id, 'cart-1');
    expect(cart.userId, GuestAuthUser.guestUid);
    expect(cart.businessId, 'biz-patil');

    final empty = ShoppingCart.fromJson({}, userId: GuestAuthUser.guestUid);
    expect(empty.id, isEmpty);

    final line = CartLine.fromJson({
      'id': 'ci-rice',
      'productId': 'prod-rice',
      'name': 'Rice (1kg)',
      'unitPrice': 120,
      'quantity': 2,
      'lineTotal': 240,
      'available': true,
    }, cartId: 'cart-1');
    expect(line.id, 'ci-rice');
    expect(line.cartId, 'cart-1');
    expect(line.productId, 'prod-rice');
    expect(line.quantity, 2);
    expect(line.product?.name, 'Rice (1kg)');
    expect(line.product?.price, 120);
    expect(line.toCheckoutItem().toRpcJson(), {
      'product_id': 'prod-rice',
      'quantity': 2,
    });
  });
}
