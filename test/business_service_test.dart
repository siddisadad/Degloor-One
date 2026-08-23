import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/catalog_product_draft.dart';
import 'package:degloor_one/shared/catalog_product_stock.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_hours.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

Shop _shop({
  String name = 'Shop',
  String? description,
  String? categoryId,
  String? whatsapp,
  String? address,
  double? lat,
  double? lng,
  String? image,
}) {
  return Shop(
    id: 'biz-test',
    name: name,
    description: description,
    categoryId: categoryId,
    whatsappNumber: whatsapp,
    addressText: address,
    latitude: lat,
    longitude: lng,
    imageUrl: image,
    isOpen: true,
    isVerified: true,
    rating: 0,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  setUp(ShowcaseCatalog.reset);

  test('guest shop catalogue lists Patil products', () async {
    final shop =
        await BusinessService.instance.requireOwned(GuestAuthUser.guestUid);
    expect(shop, isA<Shop>());
    expect(shop, isNot(isA<BusinessesRow>()));
    expect(shop.id, ShowcaseCatalog.bizPatil);

    final products =
        await BusinessService.instance.products(GuestAuthUser.guestUid);
    expect(products, everyElement(isA<CatalogProduct>()));
    expect(products, isNot(anyElement(isA<ProductsRow>())));
    expect(products.map((row) => row.id), contains(ShowcaseCatalog.prodMilk));
  });

  test('add product reuses a category without lowercasing the name', () async {
    final added = await BusinessService.instance.addProduct(
      userId: GuestAuthUser.guestUid,
      draft: const CatalogProductDraft(
        name: 'Curd',
        price: 40,
        categoryName: 'dairy',
        stockQuantity: 6,
        trackInventory: true,
      ),
    );
    expect(added, isA<CatalogProduct>());
    expect(added, isNot(isA<ProductsRow>()));
    expect(added.businessId, ShowcaseCatalog.bizPatil);
    expect(added.categoryId, 'pcat-dairy');
    expect(added.price, 40);

    final categories = await BusinessService.instance
        .productCategories(GuestAuthUser.guestUid);
    expect(categories, everyElement(isA<ProductCategory>()));
    expect(categories, isNot(anyElement(isA<ProductCategoriesRow>())));
    expect(categories.map((row) => row.name), contains('Dairy'));
    expect(categories.map((row) => row.name), isNot(contains('dairy')));
  });

  test('add product creates a typed category for a new name', () async {
    final added = await BusinessService.instance.addProduct(
      userId: GuestAuthUser.guestUid,
      draft: const CatalogProductDraft(
        name: 'Turmeric',
        price: 25,
        categoryName: 'Spices',
      ),
    );
    expect(added.categoryId, isNotEmpty);

    final created = ShowcaseCatalog.query(
      'product_categories',
      ShowcaseQuery()
        ..eq('business_id', ShowcaseCatalog.bizPatil)
        ..eq('name', 'Spices'),
    );
    expect(created, hasLength(1));
    expect(created.single['id'], added.categoryId);
    expect(created.single['created_at'], isNotNull);

    final categories = await BusinessService.instance
        .productCategories(GuestAuthUser.guestUid);
    expect(categories, everyElement(isA<ProductCategory>()));
    expect(categories.map((row) => row.name), contains('Spices'));
  });

  test('owner stock write is a quantity only', () async {
    await BusinessService.instance.updateStock(
      userId: GuestAuthUser.guestUid,
      productId: ShowcaseCatalog.prodMilk,
      stock: const CatalogProductStock(9),
    );
    final milk = ShowcaseCatalog.query(
      'products',
      ShowcaseQuery()..eq('id', ShowcaseCatalog.prodMilk),
    ).single;
    expect(milk['stock_quantity'], 9);
    expect(milk['name'], isNotEmpty);

    await expectLater(
      BusinessService.instance.updateStock(
        userId: GuestAuthUser.guestUid,
        productId: ShowcaseCatalog.prodMilk,
        stock: const CatalogProductStock(-2),
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('valid stock'),
        ),
      ),
    );
  });

  test('product mutations stay scoped to the owner', () async {
    await expectLater(
      BusinessService.instance.deleteProduct(
        userId: ShowcaseCatalog.customer2,
        productId: ShowcaseCatalog.prodMilk,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('No shop found'),
        ),
      ),
    );

    await BusinessService.instance.deleteProduct(
      userId: GuestAuthUser.guestUid,
      productId: ShowcaseCatalog.prodMilk,
    );
    final products =
        await BusinessService.instance.products(GuestAuthUser.guestUid);
    expect(products.map((row) => row.id), isNot(contains(ShowcaseCatalog.prodMilk)));
  });

  test('hours save writes TIME strings and does not duplicate days', () async {
    final hours =
        await BusinessService.instance.hours(GuestAuthUser.guestUid);
    expect(hours, hasLength(7));
    expect(hours, everyElement(isA<ShopHours>()));
    expect(hours, isNot(anyElement(isA<BusinessHoursRow>())));
    hours.first.isClosed = true;

    await BusinessService.instance.saveHours(
      userId: GuestAuthUser.guestUid,
      hours: hours,
    );

    final sunday = ShowcaseCatalog.query(
      'business_hours',
      ShowcaseQuery()
        ..eq('business_id', ShowcaseCatalog.bizPatil)
        ..eq('day_of_week', 0),
    );
    expect(sunday, hasLength(1));
    expect(sunday.single['is_closed'], isTrue);
    expect('${sunday.single['open_time']}', contains(':'));
    expect('${sunday.single['open_time']}', isNot(contains('T')));
  });

  test('customer can register an unverified shop', () async {
    final shop = await BusinessService.instance.register(
      userId: ShowcaseCatalog.customer2,
      name: 'Kale Kirana',
      ownerName: 'Priya Kale',
      phone: '9890000008',
      categoryId: ShowcaseCatalog.catGrocery,
      latitude: 18.55,
      longitude: 77.58,
      addressText: 'Lane 2, Degloor',
    );
    expect(shop.ownerId, ShowcaseCatalog.customer2);
    expect(shop.isVerified, isFalse);

    final owned =
        await BusinessService.instance.ownedBy(ShowcaseCatalog.customer2);
    expect(owned.map((row) => row.id), contains(shop.id));
  });

  test('profile update is owner scoped', () async {
    await expectLater(
      BusinessService.instance.updateProfile(
        userId: ShowcaseCatalog.customer2,
        businessId: ShowcaseCatalog.bizPatil,
        name: 'Hacked',
      ),
      throwsA(isA<Exception>()),
    );

    await BusinessService.instance.updateProfile(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
      name: 'Patil Kirana Plus',
    );
    final shop =
        await BusinessService.instance.requireOwned(GuestAuthUser.guestUid);
    expect(shop.name, 'Patil Kirana Plus');
  });

  test('completeness scores filled vs missing shop fields', () {
    expect(BusinessService.completeness(null).ratio, 0);
    expect(BusinessService.completeness(_shop(name: '')).ratio, 0);

    final full = BusinessService.completeness(
      _shop(
        name: 'Patil',
        description: 'Groceries',
        categoryId: 'c1',
        whatsapp: '+91',
        address: 'Main Road',
        lat: 18.55,
        lng: 77.58,
        image: 'https://img',
      ),
    );
    expect(full.ratio, 1);
    expect(full.percent, 100);
    expect(full.hint, 'Your profile looks great!');

    final noPhoto = BusinessService.completeness(
      _shop(
        name: 'Patil',
        description: 'Groceries',
        categoryId: 'c1',
        whatsapp: '+91',
        address: 'Main Road',
        lat: 18.55,
        lng: 77.58,
      ),
    );
    expect(noPhoto.percent, 80);
    expect(noPhoto.hint, contains('photos'));
  });
}
