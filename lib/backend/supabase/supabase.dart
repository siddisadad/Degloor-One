import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

export 'database/database.dart';

/// FlutterFlow default. Override at build time when that project is paused
/// or deleted (`net::ERR_NAME_NOT_RESOLVED` on `/auth/v1/recover`):
/// `flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...`
const kDeadFlutterFlowHost = 'uhaibenopzyzzuqjawlb.supabase.co';
const _kDefaultSupabaseUrl = 'https://$kDeadFlutterFlowHost';
const _kDefaultSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVoYWliZW5vcHp5enp1cWphd2xiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYzMDM3NDksImV4cCI6MjEwMTg3OTc0OX0.bb6O2gBGsqtotv1AarJIVo7m1HHkNf5HM7eW3LD0O5s';

String get kSupabaseUrl {
  const fromEnv = String.fromEnvironment('SUPABASE_URL');
  return fromEnv.isNotEmpty ? fromEnv : _kDefaultSupabaseUrl;
}

String get kSupabaseAnonKey {
  const fromEnv = String.fromEnvironment('SUPABASE_ANON_KEY');
  return fromEnv.isNotEmpty ? fromEnv : _kDefaultSupabaseAnonKey;
}

/// True when the compiled URL still points at the deleted FlutterFlow project.
bool get kUsesDeadFlutterFlowHost {
  final host = Uri.tryParse(kSupabaseUrl)?.host ?? '';
  return host == kDeadFlutterFlowHost;
}

/// Temporary guest mode so the app is usable while Auth is down.
/// Override with `--dart-define=BYPASS_AUTH=true|false`.
bool get kBypassAuth {
  const flag = String.fromEnvironment('BYPASS_AUTH');
  if (flag == 'true') return true;
  if (flag == 'false') return false;
  return kUsesDeadFlutterFlowHost;
}

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
