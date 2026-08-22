import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/core/error_handler.dart';

void main() {
  test('default project url is the FlutterFlow host', () {
    expect(kSupabaseUrl, 'https://uhaibenopzyzzuqjawlb.supabase.co');
    expect(SupabaseConnection.shouldSkipAuthRequest, isTrue);
    expect(
      Uri.parse(kSupabaseUrl).host,
      SupabaseConnection.deadFlutterFlowHost,
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
