import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  test('default project url is the FlutterFlow host', () {
    expect(kSupabaseUrl, 'https://uhaibenopzyzzuqjawlb.supabase.co');
    expect(kUsesDeadFlutterFlowHost, isTrue);
    expect(SupabaseConnection.shouldSkipAuthRequest, isTrue);
    expect(
      Uri.parse(kSupabaseUrl).host,
      SupabaseConnection.deadFlutterFlowHost,
    );
  });

  test('table and search RPCs use local showcase data on the dead host',
      () async {
    ShowcaseCatalog.reset();
    final users = await UsersTable().queryRows(queryFn: (q) => q);
    expect(users, isNotEmpty);
    final businesses = await BusinessesTable().searchInRadius(
      latitude: 18.55,
      longitude: 77.58,
      radiusKm: 10,
    );
    expect(businesses, isNotEmpty);
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
      SupabaseConnection.unreachableMessage,
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

  test('AuthRetryableFetchException message is treated as unreachable', () {
    const fetch =
        'ClientException: Failed to fetch, uri=https://uhaibenopzyzzuqjawlb.supabase.co/auth/v1/token?grant_type=password';
    expect(
      SupabaseConnection.messageFor(
        Exception('AuthRetryableFetchException(message: $fetch)'),
        authMessage: fetch,
      ),
      SupabaseConnection.unreachableMessage,
    );
    expect(
      SupabaseConnection.messageFor(
        Exception('AuthException'),
        authMessage: fetch,
      ),
      SupabaseConnection.unreachableMessage,
    );
    expect(
      SupabaseConnection.messageFor(
        Exception(
          'AuthRetryableFetchException(message: ClientException: Failed to fetch, '
          'uri=https://uhaibenopzyzzuqjawlb.supabase.co/auth/v1/otp?)',
        ),
      ),
      SupabaseConnection.unreachableMessage,
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
