import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';

void main() {
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
}
