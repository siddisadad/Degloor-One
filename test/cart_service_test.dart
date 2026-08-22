import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
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
    expect(items.first['products'], isA<Map<String, dynamic>>());
    expect(
      items.any((item) => item['product_id'] == ShowcaseCatalog.prodRice),
      isTrue,
    );
  });

  test('addProduct increments quantity on the guest cart', () async {
    final before = await CartService.itemsForCart(ShowcaseCatalog.cartGuest);
    final riceBefore = before.firstWhere(
      (item) => item['product_id'] == ShowcaseCatalog.prodRice,
    );

    final result = await CartService.addProduct(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
      productId: ShowcaseCatalog.prodRice,
    );
    expect(result.added, isTrue);

    final after = await CartService.itemsForCart(ShowcaseCatalog.cartGuest);
    final riceAfter = after.firstWhere(
      (item) => item['product_id'] == ShowcaseCatalog.prodRice,
    );
    expect(riceAfter['quantity'], (riceBefore['quantity'] as int) + 1);
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
      items.any((item) => item['product_id'] == ShowcaseCatalog.prodThali),
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
    expect(carts.first.businessId, ShowcaseCatalog.bizHotel);
    final items = await CartService.itemsForCart(carts.first.id);
    expect(
      items.any((item) => item['product_id'] == ShowcaseCatalog.prodThali),
      isTrue,
    );
  });
}
