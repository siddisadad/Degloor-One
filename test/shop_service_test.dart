import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_event.dart';
import 'package:degloor_one/shared/shop_hours.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

DateTime _clock(String raw) {
  final parts = raw.split(':');
  return DateTime(1970, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
}

ShopHours _hours({
  required int day,
  required String open,
  required String close,
  bool closed = false,
}) {
  return ShopHours(
    id: 'h-$day-$open',
    businessId: 'biz',
    dayOfWeek: day,
    openTime: _clock(open),
    closeTime: _clock(close),
    isClosed: closed,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  setUp(ShowcaseCatalog.reset);

  test('Patil catalogue lists milk, rice, and category names', () async {
    final catalog =
        await ShopService.instance.catalog(ShowcaseCatalog.bizPatil);
    expect(catalog.products, everyElement(isA<CatalogProduct>()));
    expect(catalog.products, isNot(anyElement(isA<ProductsRow>())));
    expect(
      catalog.products.map((row) => row.id),
      containsAll([ShowcaseCatalog.prodMilk, ShowcaseCatalog.prodRice]),
    );
    expect(catalog.categories, everyElement(isA<ProductCategory>()));
    expect(catalog.categories, isNot(anyElement(isA<ProductCategoriesRow>())));
    expect(
      catalog.categories.map((row) => row.name),
      containsAll(['Dairy', 'Grains']),
    );
    expect(catalog.grouped['pcat-dairy']!.single.name, 'Fresh Milk (1L)');
    expect(catalog.grouped['pcat-grains']!.single.id, ShowcaseCatalog.prodRice);
  });

  test('Patil reviews include a 1-5 distribution on showcase', () async {
    final reviews =
        await ShopService.instance.reviews(ShowcaseCatalog.bizPatil);
    expect(reviews.items, hasLength(2));
    expect(reviews.items, everyElement(isA<ShopReview>()));
    expect(reviews.items, isNot(anyElement(isA<ReviewsRow>())));
    expect(reviews.distribution[5], 1);
    expect(reviews.distribution[4], 1);
    expect(reviews.distribution[1], 0);
  });

  test('customer2 cannot review Patil twice', () async {
    await expectLater(
      ShopService.instance.addReview(
        userId: ShowcaseCatalog.customer2,
        businessId: ShowcaseCatalog.bizPatil,
        rating: 3,
        comment: 'Again',
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('already reviewed'),
        ),
      ),
    );
  });

  test('guest can review a shop they have not reviewed', () async {
    await ShopService.instance.addReview(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizHotel,
      rating: 4,
      comment: 'Good thali',
    );
    final reviews =
        await ShopService.instance.reviews(ShowcaseCatalog.bizHotel);
    expect(reviews.items, hasLength(2));
    expect(reviews.items, everyElement(isA<ShopReview>()));
    expect(reviews.items, isNot(anyElement(isA<ReviewsRow>())));
    expect(
      reviews.items.any((row) => row.userId == GuestAuthUser.guestUid),
      isTrue,
    );
    final stored = ShowcaseCatalog.query(
      'reviews',
      ShowcaseQuery()
        ..eq('user_id', GuestAuthUser.guestUid)
        ..eq('business_id', ShowcaseCatalog.bizHotel),
    ).single;
    expect(stored['rating'], 4);
    expect(stored['comment'], 'Good thali');
    expect(stored.containsKey('author'), isFalse);
  });

  test('guest already has the seeded hotel complaint', () async {
    final complaints = await ShopService.instance
        .complaintsForUser(GuestAuthUser.guestUid);
    expect(complaints, everyElement(isA<ListingComplaint>()));
    expect(complaints, isNot(anyElement(isA<ComplaintsRow>())));
    expect(complaints, hasLength(1));
    expect(complaints.single.id, 'cmp-1');
    expect(complaints.single.status, 'pending');
    expect(complaints.single.subject, 'Missing sweet in thali');
  });

  test('reportListing stores a pending complaint', () async {
    final created = await ShopService.instance.reportListing(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizHotel,
      subject: 'Closed early',
      description: 'Shop closed before advertised hours.',
    );
    expect(created, isA<ListingComplaint>());
    expect(created, isNot(isA<ComplaintsRow>()));
    expect(created.subject, 'Closed early');
    expect(created.status, 'pending');
    final complaints = await ShopService.instance
        .complaintsForUser(GuestAuthUser.guestUid);
    expect(complaints, hasLength(2));
    expect(
      complaints.any((row) => row.subject == 'Closed early'),
      isTrue,
    );
    expect(
      complaints.every((row) => row.status == 'pending'),
      isTrue,
    );
  });

  test('summarizeEvents counts types and daily buckets', () async {
    final events = await ShopService.instance.eventsFor(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
    );
    expect(events, everyElement(isA<ShopEvent>()));
    expect(events, isNot(anyElement(isA<BusinessAnalyticsRow>())));
    final summary = ShopService.summarizeEvents(events);
    expect(summary.profileViews, 18);
    expect(summary.callClicks, 5);
    expect(summary.whatsappClicks, 7);
    expect(summary.directionsClicks, 3);
    expect(summary.inquiries, 12);
    expect(summary.conversionRate, closeTo(12 / 18 * 100, 0.001));
    expect(summary.dailyCounts, isNotEmpty);
    expect(summary.peakDaily, greaterThan(0));
    expect(ShopService.summarizeEvents(const []).profileViews, 0);
  });

  test('eventsFor returns owner-scoped analytics', () async {
    final events = await ShopService.instance.eventsFor(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
    );
    expect(events, isNotEmpty);
    expect(events, everyElement(isA<ShopEvent>()));
    expect(events, isNot(anyElement(isA<BusinessAnalyticsRow>())));
    expect(
      events.every((row) => row.businessId == ShowcaseCatalog.bizPatil),
      isTrue,
    );
    expect(
      events.where((row) => row.eventType == 'PROFILE_VIEW'),
      hasLength(18),
    );
  });

  test('byId returns the Patil shop domain type', () async {
    final shop = await ShopService.instance.byId(ShowcaseCatalog.bizPatil);
    expect(shop, isA<Shop>());
    expect(shop, isNot(isA<BusinessesRow>()));
    expect(shop?.id, ShowcaseCatalog.bizPatil);
    expect(shop?.name, isNotEmpty);
    expect(await ShopService.instance.byId(''), isNull);
  });

  test('productById returns Patil milk on showcase', () async {
    final product =
        await ShopService.instance.productById(ShowcaseCatalog.prodMilk);
    expect(product, isA<CatalogProduct>());
    expect(product, isNot(isA<ProductsRow>()));
    expect(product!.id, ShowcaseCatalog.prodMilk);
    expect(product.name, 'Fresh Milk (1L)');
    expect(product.businessId, ShowcaseCatalog.bizPatil);
    expect(product.price, 60);
    expect(product.isAvailable, isTrue);
  });

  test('productById returns null for an unknown product', () async {
    expect(await ShopService.instance.productById('prod-missing'), isNull);
    expect(await ShopService.instance.productById(''), isNull);
  });

  test('trackEvent inserts a product view on showcase', () async {
    await ShopService.instance.trackEvent(
      businessId: ShowcaseCatalog.bizPatil,
      eventType: ShopEvents.productView,
      userId: GuestAuthUser.guestUid,
      metadata: {'product_id': ShowcaseCatalog.prodMilk},
    );
    final events = await ShopService.instance.eventsFor(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
    );
    final views = events.where((row) => row.eventType == ShopEvents.productView);
    expect(views, hasLength(1));
    expect(views.single.businessId, ShowcaseCatalog.bizPatil);
  });

  test('trackEvent ignores empty ids', () async {
    await ShopService.instance.trackEvent(
      businessId: '',
      eventType: ShopEvents.profileView,
    );
    final events = await ShopService.instance.eventsFor(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
    );
    expect(
      events.where((row) => row.eventType == ShopEvents.profileView),
      hasLength(18),
    );
  });

  test('hours returns shop hours instead of table rows', () async {
    final hours = await ShopService.instance.hours(ShowcaseCatalog.bizPatil);
    expect(hours, isNotEmpty);
    expect(hours, everyElement(isA<ShopHours>()));
    expect(hours, isNot(anyElement(isA<BusinessHoursRow>())));
  });

  test('isOpenFromHours handles same-day, overnight, and closed rows', () {
    final sundayMorning = DateTime(2026, 8, 23, 10, 0);
    final sundayLate = DateTime(2026, 8, 23, 22, 0);
    final sundayOvernight = DateTime(2026, 8, 23, 1, 0);
    final weekday = [
      _hours(day: 0, open: '09:00:00', close: '21:00:00'),
    ];
    final overnight = [
      _hours(day: 0, open: '22:00:00', close: '02:00:00'),
    ];

    expect(ShopService.isOpenFromHours(weekday, now: sundayMorning), isTrue);
    expect(ShopService.isOpenFromHours(weekday, now: sundayLate), isFalse);
    expect(ShopService.isOpenFromHours(const [], now: sundayMorning), isFalse);
    expect(
      ShopService.isOpenFromHours(
        [_hours(day: 0, open: '09:00:00', close: '21:00:00', closed: true)],
        now: sundayMorning,
      ),
      isFalse,
    );
    expect(ShopService.isOpenFromHours(overnight, now: sundayLate), isTrue);
    expect(ShopService.isOpenFromHours(overnight, now: sundayOvernight), isTrue);
    expect(ShopService.isOpenFromHours(overnight, now: sundayMorning), isFalse);
  });

  test('isOpenNow and isOpenNowBatch use showcase hours', () async {
    final morning = DateTime(2026, 8, 23, 10, 0);
    final late = DateTime(2026, 8, 23, 22, 0);

    expect(
      await ShopService.instance.isOpenNow(ShowcaseCatalog.bizPatil, now: morning),
      isTrue,
    );
    expect(
      await ShopService.instance.isOpenNow(ShowcaseCatalog.bizPatil, now: late),
      isFalse,
    );
    expect(
      await ShopService.instance
          .isOpenNow(ShowcaseCatalog.bizMedical, now: late),
      isTrue,
    );
    expect(await ShopService.instance.isOpenNow(''), isFalse);

    final batch = await ShopService.instance.isOpenNowBatch(
      [ShowcaseCatalog.bizPatil, ShowcaseCatalog.bizMedical],
      now: late,
    );
    expect(batch[ShowcaseCatalog.bizPatil], isFalse);
    expect(batch[ShowcaseCatalog.bizMedical], isTrue);
  });

  test('eventsFor rejects a shop the user does not own', () async {
    await expectLater(
      ShopService.instance.eventsFor(
        userId: ShowcaseCatalog.customer2,
        businessId: ShowcaseCatalog.bizPatil,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('No shop found'),
        ),
      ),
    );
  });
}
