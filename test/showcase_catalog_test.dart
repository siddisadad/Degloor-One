import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('showcase catalog covers the main Degloor features', () {
    expect(kUseShowcaseData, isTrue);
    expect(ShowcaseCatalog.table('business_categories').length, greaterThanOrEqualTo(7));
    expect(ShowcaseCatalog.table('businesses').length, greaterThanOrEqualTo(7));
    expect(ShowcaseCatalog.table('products'), isNotEmpty);
    expect(ShowcaseCatalog.table('service_providers'), isNotEmpty);
    expect(ShowcaseCatalog.table('jobs'), isNotEmpty);
    expect(ShowcaseCatalog.table('orders'), isNotEmpty);
    expect(ShowcaseCatalog.table('notifications'), isNotEmpty);
    expect(ShowcaseCatalog.table('addresses'), isNotEmpty);

    final nearby = ShowcaseCatalog.searchBusinesses(
      latitude: ShowcaseCatalog.degloorLat,
      longitude: ShowcaseCatalog.degloorLng,
      radiusKm: 10,
    );
    expect(nearby, isNotEmpty);
    expect(nearby.first['distance_km'], lessThan(5));

    final patil = ShowcaseCatalog.query(
      'businesses',
      ShowcaseQuery()..eq('id', ShowcaseCatalog.bizPatil),
    );
    expect(patil, hasLength(1));
    expect(patil.first['owner_id'], GuestAuthUser.guestUid);

    final cart = ShowcaseCatalog.cartItemsWithProducts(ShowcaseCatalog.cartGuest);
    expect(cart, isNotEmpty);
    expect(cart.first['products']['name'], isNotEmpty);

    final providers = ShowcaseCatalog.serviceProviders();
    expect(providers.first['users']['full_name'], isNotEmpty);
    expect(ShowcaseCatalog.serviceProvider('sp-ravi'), isNotNull);

    final jobs = ShowcaseCatalog.activeJobs();
    expect(jobs.first['businesses']['name'], isNotEmpty);
  });

  test('showcase insert and filter keep cart writes local', () {
    final created = ShowcaseCatalog.insert('carts', {
      'user_id': GuestAuthUser.guestUid,
      'business_id': ShowcaseCatalog.bizHotel,
    });
    expect(created['id'], isNotEmpty);
    final found = ShowcaseCatalog.query(
      'carts',
      ShowcaseQuery()..eq('id', created['id']),
    );
    expect(found, hasLength(1));
  });

  test('showcase query neq excludes matching rows', () {
    final open = ShowcaseCatalog.query(
      'orders',
      ShowcaseQuery()..neq('status', 'delivered'),
    );
    expect(open, isNotEmpty);
    expect(
      open.every((row) => row['status'] != 'delivered'),
      isTrue,
    );
  });
}
