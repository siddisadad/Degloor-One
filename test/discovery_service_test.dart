import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const discoveryChannel = MethodChannel('com.deshmukh.degloorone/discovery');

  setUp(ShowcaseCatalog.reset);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(discoveryChannel, null);
  });

  test('showcase discovery categories skip the native channel', () async {
    var invoked = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(discoveryChannel, (call) async {
      invoked += 1;
      return const [];
    });

    expect(kUseShowcaseData, isTrue);
    final categories = await DiscoveryService.instance.categories();
    expect(invoked, 0);
    expect(categories, isNotEmpty);
  });

  test('discovery search paginates nearby Degloor businesses', () async {
    expect(kUseShowcaseData, isTrue);
    const firstPage = PageQuery(limit: 3);
    final first = await DiscoveryService.instance.search(
      const DiscoverySearch(
        latitude: ShowcaseCatalog.degloorLat,
        longitude: ShowcaseCatalog.degloorLng,
        radiusKm: 15,
        page: firstPage,
      ),
    );
    expect(first.items, hasLength(3));
    expect(first.hasMore, isTrue);
    expect(first.items, everyElement(isA<Shop>()));
    expect(first.items, isNot(anyElement(isA<BusinessesRow>())));

    final second = await DiscoveryService.instance.search(
      DiscoverySearch(
        latitude: ShowcaseCatalog.degloorLat,
        longitude: ShowcaseCatalog.degloorLng,
        radiusKm: 15,
        page: firstPage.next(),
      ),
    );
    expect(second.items, isNotEmpty);
    expect(
      second.items.map((row) => row.id),
      isNot(contains(first.items.first.id)),
    );
  });

  test('master search for milk returns the product and Patil shop', () async {
    final result = await DiscoveryService.instance.masterSearch(
      query: const DiscoverySearch(
        latitude: ShowcaseCatalog.degloorLat,
        longitude: ShowcaseCatalog.degloorLng,
        radiusKm: 15,
        searchTerm: 'milk',
      ),
    );
    expect(result.products.map((row) => row.id), contains(ShowcaseCatalog.prodMilk));
    expect(result.shops.map((row) => row.id), contains(ShowcaseCatalog.bizPatil));
    expect(result.totalCount, greaterThanOrEqualTo(2));
  });

  test('master search scopes services and jobs', () async {
    final services = await DiscoveryService.instance.masterSearch(
      query: const DiscoverySearch(
        latitude: ShowcaseCatalog.degloorLat,
        longitude: ShowcaseCatalog.degloorLng,
        radiusKm: 15,
        searchTerm: 'electric',
      ),
      scope: MasterSearchScope.services,
    );
    expect(services.shops, isEmpty);
    expect(services.services, isNotEmpty);
    expect(
      services.services.any((row) => row.categoryName.toLowerCase().contains('electric')),
      isTrue,
    );

    final jobs = await DiscoveryService.instance.masterSearch(
      query: const DiscoverySearch(
        latitude: ShowcaseCatalog.degloorLat,
        longitude: ShowcaseCatalog.degloorLng,
        radiusKm: 15,
        searchTerm: 'counter',
      ),
      scope: MasterSearchScope.jobs,
    );
    expect(jobs.jobs.map((row) => row.id), contains('job-counter'));
  });

  test('product search returns catalog products', () async {
    final page = await DiscoveryService.instance.searchProducts(
      const DiscoverySearch(
        latitude: ShowcaseCatalog.degloorLat,
        longitude: ShowcaseCatalog.degloorLng,
        radiusKm: 15,
        page: PageQuery(limit: 5),
      ),
    );
    expect(page.items, isNotEmpty);
    expect(page.items, everyElement(isA<CatalogProduct>()));
    expect(page.items, isNot(anyElement(isA<ProductsRow>())));
    expect(page.items.map((row) => row.id), contains(ShowcaseCatalog.prodMilk));
  });

  test('discovery categories and profile use the showcase catalog', () async {
    final categories = await DiscoveryService.instance.categories();
    expect(categories.length, greaterThanOrEqualTo(7));
    expect(categories, everyElement(isA<ShopCategory>()));
    expect(categories, isNot(anyElement(isA<BusinessCategoriesRow>())));
    expect(categories.first.displayOrder, isNotNull);

    final profile =
        await DiscoveryService.instance.profile(GuestAuthUser.guestUid);
    expect(profile, hasLength(1));
    expect(profile.first.id, GuestAuthUser.guestUid);
  });

    test('owned shops and id lookups use the catalog', () async {
    final guestShops =
        await DiscoveryService.instance.ownedBy(GuestAuthUser.guestUid);
    expect(guestShops.map((row) => row.id), contains(ShowcaseCatalog.bizPatil));

    final hotel = await DiscoveryService.instance.ownedBy(ShowcaseCatalog.owner2);
    expect(hotel.map((row) => row.id), contains(ShowcaseCatalog.bizHotel));

    final shops = await DiscoveryService.instance.businessesByIds([
      ShowcaseCatalog.bizPatil,
    ]);
    expect(shops, hasLength(1));
    expect(shops, everyElement(isA<Shop>()));
    expect(shops, isNot(anyElement(isA<BusinessesRow>())));
    expect(shops.first.name, isNotEmpty);
  });

  test('shop insights count reviews and analytics events', () async {
    final insights =
        await DiscoveryService.instance.insightsFor(ShowcaseCatalog.bizPatil);
    expect(insights.reviewCount, 2);
    expect(insights.profileViews, 18);
    expect(insights.callClicks, 5);
    expect(insights.whatsappClicks, 7);
    expect(insights.directionsClicks, 3);

    expect(
      await DiscoveryService.instance.insightsFor(''),
      ShopInsights.empty,
    );
  });
}
