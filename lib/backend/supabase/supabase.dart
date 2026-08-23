import 'package:degloor_one/core/app_environment.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:degloor_one/core/app_flags.dart';
export 'database/database.dart';

/// FlutterFlow default. Override at build time when that project is paused
/// or deleted (`net::ERR_NAME_NOT_RESOLVED` on `/auth/v1/recover`):
/// `flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...`
const kDeadFlutterFlowHost = AppEnvironment.deadFlutterFlowHost;

String get kSupabaseUrl => AppEnvironment.supabaseUrl;

String get kSupabaseAnonKey => AppEnvironment.supabaseAnonKey;

/// Throws immediately so Chrome never POSTs to a host that NXDOMAINs.
class BlockedSupabaseHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw http.ClientException('Failed to fetch', request.url);
  }
}

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() {
    final skip = kUsesDeadFlutterFlowHost;
    return Supabase.initialize(
      url: kSupabaseUrl,
      headers: {
        'X-Client-Info': 'flutterflow',
      },
      anonKey: kSupabaseAnonKey,
      debug: false,
      httpClient: skip ? BlockedSupabaseHttpClient() : null,
      authOptions: FlutterAuthClientOptions(
        autoRefreshToken: !skip,
        localStorage: skip ? const EmptyLocalStorage() : null,
        detectSessionInUri: !skip,
      ),
    );
  }
}
