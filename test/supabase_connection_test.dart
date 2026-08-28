import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUp(() {
    AppEnvironment.debugReset();
    AppEnvironment.debugOverride(
      flavor: AppFlavor.development,
      bypassAuth: true,
      useShowcaseData: false,
    );
  });

  tearDown(() {
    AppEnvironment.debugReset();
  });

  test('default project url is the FlutterFlow host', () {
    expect(kSupabaseUrl, 'https://uhaibenopzyzzuqjawlb.supabase.co');
    expect(kUsesDeadFlutterFlowHost, isTrue);
    expect(kShouldBlockSupabaseTraffic, isTrue);
    expect(SupabaseConnection.shouldSkipAuthRequest, isTrue);
    expect(
      Uri.parse(kSupabaseUrl).host,
      SupabaseConnection.deadFlutterFlowHost,
    );
  });

  test('a live GoTrue health probe unblocks table reads on the FlutterFlow host',
      () async {
    expect(kShouldBlockSupabaseTraffic, isTrue);
    expect(kUseShowcaseData, isTrue);
    expect(kBypassAuth, isTrue);

    final client = MockClient((request) async {
      expect(request.url.path, '/auth/v1/health');
      return http.Response(
        '{"version":"v2.195.0","name":"GoTrue","description":"GoTrue"}',
        200,
      );
    });
    await SupabaseConnection.discoverLiveHost(client: client);

    expect(AppEnvironment.flutterFlowHostIsLive, isTrue);
    expect(kShouldBlockSupabaseTraffic, isFalse);
    expect(kUseShowcaseData, isFalse);
    expect(kBypassAuth, isTrue);
    expect(SupabaseConnection.shouldSkipAuthRequest, isFalse);
  });

  test('a failed health probe keeps the FlutterFlow host blocked', () async {
    final client = MockClient((request) async {
      throw http.ClientException('Failed to fetch', request.url);
    });
    expect(await SupabaseConnection.probeLive(client: client), isFalse);
    await SupabaseConnection.discoverLiveHost(client: client);
    expect(AppEnvironment.flutterFlowHostIsLive, isFalse);
    expect(kShouldBlockSupabaseTraffic, isTrue);
    expect(kUseShowcaseData, isTrue);
  });

  test('live search RPCs match the restored project signature', () {
    final shops = BusinessesTable.liveSearchParams(
      latitude: 18.55,
      longitude: 77.58,
      radiusKm: 15,
    );
    expect(
      shops.keys,
      unorderedEquals(['user_lat', 'user_lng', 'radius_meters']),
    );
    expect(shops.containsKey('p_limit'), isFalse);
    expect(shops.containsKey('open_now'), isFalse);

    final products = ProductsTable.liveSearchParams(
      latitude: 18.55,
      longitude: 77.58,
      radiusKm: 15,
    );
    expect(products.containsKey('p_limit'), isFalse);
    expect(products.containsKey('p_offset'), isFalse);

    final rows = [
      BusinessesRow({
        'id': 'open',
        'name': 'Open Shop',
        'is_open': true,
        'is_verified': true,
        'rating': 4.5,
        'created_at': '2026-01-01T00:00:00.000Z',
      }),
      BusinessesRow({
        'id': 'closed',
        'name': 'Closed Shop',
        'is_open': false,
        'is_verified': true,
        'rating': 4.5,
        'created_at': '2026-01-01T00:00:00.000Z',
      }),
    ];
    expect(
      BusinessesTable.applyLiveSearchFilters(rows, openNow: true)
          .map((row) => row.id),
      ['open'],
    );
  });

  test('live search fills distance_km from the query origin', () {
    expect(
      LatLng.distanceKm(18.5522, 77.5844, 18.5522, 77.5844),
      0,
    );
    final farther = BusinessesRow({
      'id': 'far',
      'name': 'Far Shop',
      'latitude': 18.56,
      'longitude': 77.59,
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    final nearer = BusinessesRow({
      'id': 'near',
      'name': 'Near Shop',
      'latitude': 18.5528,
      'longitude': 77.5848,
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    final kept = BusinessesRow({
      'id': 'kept',
      'name': 'Kept Distance',
      'latitude': 18.56,
      'longitude': 77.59,
      'distance_km': 9.9,
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    final ranked = BusinessesTable.applyLiveSearchFilters(
      [farther, nearer, kept],
      originLat: 18.5522,
      originLng: 77.5844,
    );
    expect(ranked.map((row) => row.id), ['near', 'far', 'kept']);
    expect(ranked.first.distanceKm, closeTo(0.08, 0.05));
    expect(ranked[1].distanceKm, greaterThan(ranked.first.distanceKm!));
    expect(ranked.last.distanceKm, 9.9);
  });

  test('live table rows keep Degloor shops inside the radius', () {
    final ganesh = BusinessesRow({
      'id': 'a3bb4c14-9fb4-42bf-b4d2-41713a6d80d1',
      'name': 'Ganesh Sweet Mart',
      'description': 'Famous for Degloor Pedha and fresh sweets.',
      'address_text': 'Subhash Chowk, Degloor',
      'latitude': 18.5528,
      'longitude': 77.5848,
      'is_open': true,
      'is_verified': true,
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    final outside = BusinessesRow({
      'id': 'far-away',
      'name': 'Other City Shop',
      'latitude': 19.07,
      'longitude': 72.87,
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    final nearby = BusinessesTable.filterLiveTableRows(
      [ganesh, outside],
      latitude: 18.5522,
      longitude: 77.5844,
      radiusKm: 10,
    );
    expect(nearby.map((row) => row.name), ['Ganesh Sweet Mart']);
    expect(nearby.single.distanceKm, lessThan(1));

    final sweets = BusinessesTable.filterLiveTableRows(
      [ganesh, outside],
      latitude: 18.5522,
      longitude: 77.5844,
      radiusKm: 10,
      searchTerm: 'pedha',
    );
    expect(sweets.map((row) => row.name), ['Ganesh Sweet Mart']);
  });

  test('live product rows use the shop coordinates for distance', () {
    final ganesh = BusinessesRow({
      'id': 'shop-ganesh',
      'name': 'Ganesh Sweet Mart',
      'latitude': 18.5528,
      'longitude': 77.5848,
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    final pedha = ProductsRow({
      'id': 'prod-pedha',
      'business_id': 'shop-ganesh',
      'name': 'Degloor Pedha',
      'description': 'Famous sweet from Degloor.',
      'price': 40,
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    final orphan = ProductsRow({
      'id': 'prod-orphan',
      'business_id': 'missing-shop',
      'name': 'Orphan Item',
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    final farShop = BusinessesRow({
      'id': 'shop-far',
      'name': 'Other City Shop',
      'latitude': 19.07,
      'longitude': 72.87,
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    final far = ProductsRow({
      'id': 'prod-far',
      'business_id': 'shop-far',
      'name': 'Far Item',
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    final nearby = ProductsTable.filterLiveTableRows(
      [pedha, orphan, far],
      [ganesh, farShop],
      latitude: 18.5522,
      longitude: 77.5844,
      radiusKm: 10,
      searchTerm: 'pedha',
    );
    expect(nearby.map((row) => row.id), ['prod-pedha']);
    expect(nearby.single.distanceKm, lessThan(1));
  });

  test('live PostgREST JS arrays become typed table rows', () {
    final rows = BusinessesTable().rowsFromWire(<dynamic>[
      <dynamic, dynamic>{
        'id': 'a3bb4c14-9fb4-42bf-b4d2-41713a6d80d1',
        'name': 'Ganesh Sweet Mart',
        'created_at': '2026-01-01T00:00:00.000Z',
      },
    ]);
    expect(rows, hasLength(1));
    expect(rows.single, isA<BusinessesRow>());
    expect(rows.single.name, 'Ganesh Sweet Mart');

    final users = List<UsersRow>.from(
      UsersTable().rowsFromWire(<dynamic>[
        <dynamic, dynamic>{
          'id': '00000000-0000-4000-8000-000000000001',
          'full_name': 'Guest Customer',
          'email': 'guest@local',
          'created_at': '2026-01-01T00:00:00.000Z',
        },
      ]),
    );
    expect(users, isA<List<UsersRow>>());
    expect(users.single.fullName, 'Guest Customer');

    final products = ProductsTable().rowsFromWire(<dynamic>[
      <dynamic, dynamic>{
        'id': 'prod-pedha',
        'business_id': 'shop-ganesh',
        'name': 'Degloor Pedha',
        'created_at': '2026-01-01T00:00:00.000Z',
      },
    ]);
    expect(products, hasLength(1));
    expect(products.single, isA<ProductsRow>());
    expect(products.single.name, 'Degloor Pedha');
  });

  test('table and search RPCs use local showcase data on the dead host',
      () async {
    ShowcaseCatalog.reset();
    final users = await UsersTable().queryRows(queryFn: (q) => q);
    expect(users.map((row) => row.fullName), contains('Guest Customer'));
    final businesses = await BusinessesTable().searchInRadius(
      latitude: 18.55,
      longitude: 77.58,
      radiusKm: 10,
    );
    expect(
      businesses.map((row) => row.name),
      contains('Patil Kirana Store'),
    );
    expect(businesses.first.distanceKm, isNotNull);
    final products = await ProductsTable().searchInRadius(
      latitude: 18.55,
      longitude: 77.58,
      radiusKm: 10,
    );
    expect(products, isNotEmpty);
  });

  test('blocked http client never opens a socket', () async {
    final request = http.Request(
      'POST',
      Uri.parse('$kSupabaseUrl/auth/v1/token?grant_type=password'),
    );
    expect(
      () => BlockedSupabaseHttpClient().send(request),
      throwsA(
        isA<http.ClientException>().having(
          (e) => e.message,
          'message',
          contains('Failed to fetch'),
        ),
      ),
    );
  });

  test('maps DNS and browser fetch failures to the unreachable message', () {
    expect(
      SupabaseConnection.looksUnreachable(
        Exception('Failed host lookup: uhaibenopzyzzuqjawlb.supabase.co'),
      ),
      isTrue,
    );
    expect(
      SupabaseConnection.looksUnreachable(
        Exception('ClientException: XMLHttpRequest error'),
      ),
      isTrue,
    );
    expect(
      SupabaseConnection.looksUnreachable(
        Exception(
          'AuthRetryableFetchException(message: ClientException: Failed to fetch, '
          'uri=https://uhaibenopzyzzuqjawlb.supabase.co/auth/v1/token?grant_type=password)',
        ),
      ),
      isTrue,
    );
    expect(
      SupabaseConnection.messageFor(
        Exception('net::ERR_NAME_NOT_RESOLVED'),
      ),
      SupabaseConnection.guestUnreachableMessage,
    );
    expect(
      SupabaseConnection.messageFor(Exception('net::ERR_NAME_NOT_RESOLVED')),
      isNot(contains('SUPABASE_URL')),
    );
    expect(
      SupabaseConnection.messageFor(Exception('net::ERR_NAME_NOT_RESOLVED')),
      isNot(contains('Skipped Auth request')),
    );
  });

  test('keeps auth messages when the host is reachable', () {
    expect(
      SupabaseConnection.messageFor(
        Exception('AuthApiException'),
        authMessage: 'Invalid login credentials',
      ),
      'Error: Invalid login credentials',
    );
  });

  test('AuthApiException dump does not reach the customer', () {
    const dumped =
        'AuthApiException(message: email rate limit exceeded, statusCode: 429, code: over_email_send_rate_limit)';
    expect(
      SupabaseConnection.messageFor(Exception(dumped)),
      'Please wait a moment before trying again.',
    );
    expect(
      SupabaseConnection.messageFor(Exception(dumped)),
      isNot(contains('AuthApiException')),
    );
    expect(
      SupabaseConnection.messageFor(
        Exception(
          'AuthApiException(message: Invalid login credentials, statusCode: 400, code: invalid_credentials)',
        ),
      ),
      'Error: Invalid login credentials',
    );
    expect(
      SupabaseConnection.messageFor(
        const AuthException('User already registered'),
      ),
      'Error: The email is already in use by a different account',
    );
  });

  test('AuthRetryableFetchException message is treated as unreachable', () {
    const fetch =
        'ClientException: Failed to fetch, uri=https://uhaibenopzyzzuqjawlb.supabase.co/auth/v1/token?grant_type=password';
    expect(
      SupabaseConnection.messageFor(
        Exception('AuthRetryableFetchException(message: $fetch)'),
        authMessage: fetch,
      ),
      SupabaseConnection.guestUnreachableMessage,
    );
    expect(
      SupabaseConnection.messageFor(
        Exception('AuthException'),
        authMessage: fetch,
      ),
      SupabaseConnection.guestUnreachableMessage,
    );
    expect(
      SupabaseConnection.messageFor(
        Exception(
          'AuthRetryableFetchException(message: ClientException: Failed to fetch, '
          'uri=https://uhaibenopzyzzuqjawlb.supabase.co/auth/v1/otp?)',
        ),
      ),
      SupabaseConnection.guestUnreachableMessage,
    );
  });

  test('AppLogger treats the console AuthRetryableFetchException as unreachable',
      () {
    const dumped =
        'AuthRetryableFetchException(message: ClientException: Failed to fetch, '
        'uri=https://uhaibenopzyzzuqjawlb.supabase.co/auth/v1/token?grant_type=password, '
        'statusCode: null)';
    expect(AppLogger.isUnreachable(Exception(dumped)), isTrue);
  });
}
