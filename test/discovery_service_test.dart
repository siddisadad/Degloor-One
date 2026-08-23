import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/repositories/discovery_repository.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('discovery search paginates nearby Degloor businesses', () async {
    expect(kUseShowcaseData, isTrue);
    const firstPage = PageQuery(limit: 3);
    final first = await DiscoveryService.instance.search(
      DiscoverySearch(
        latitude: ShowcaseCatalog.degloorLat,
        longitude: ShowcaseCatalog.degloorLng,
        radiusKm: 15,
        page: firstPage,
      ),
    );
    expect(first.items, hasLength(3));
    expect(first.hasMore, isTrue);

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

  test('discovery categories and profile use the showcase catalog', () async {
    final categories = await DiscoveryService.instance.categories();
    expect(categories.length, greaterThanOrEqualTo(7));
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
