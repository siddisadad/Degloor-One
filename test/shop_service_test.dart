import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('Patil catalogue lists milk, rice, and category names', () async {
    final catalog =
        await ShopService.instance.catalog(ShowcaseCatalog.bizPatil);
    expect(
      catalog.products.map((row) => row.id),
      containsAll([ShowcaseCatalog.prodMilk, ShowcaseCatalog.prodRice]),
    );
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
    expect(
      reviews.items.any((row) => row['user_id'] == GuestAuthUser.guestUid),
      isTrue,
    );
  });

  test('guest already has the seeded hotel complaint', () async {
    final complaints = await ShopService.instance
        .complaintsForUser(GuestAuthUser.guestUid);
    expect(complaints, hasLength(1));
    expect(complaints.single.id, 'cmp-1');
    expect(complaints.single.status, 'pending');
    expect(complaints.single.subject, 'Missing sweet in thali');
  });

  test('reportListing stores a pending complaint', () async {
    await ShopService.instance.reportListing(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizHotel,
      subject: 'Closed early',
      description: 'Shop closed before advertised hours.',
    );
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

  test('eventsFor returns owner-scoped analytics', () async {
    final events = await ShopService.instance.eventsFor(
      userId: GuestAuthUser.guestUid,
      businessId: ShowcaseCatalog.bizPatil,
    );
    expect(events, isNotEmpty);
    expect(
      events.every((row) => row.businessId == ShowcaseCatalog.bizPatil),
      isTrue,
    );
    expect(
      events.where((row) => row.eventType == 'PROFILE_VIEW'),
      hasLength(18),
    );
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
