/// Dart-define switches used by DEGLOOR ONE.
///
/// Production builds must pass a live project:
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
/// `--dart-define=BYPASS_AUTH=false --dart-define=SHOWCASE_DATA=false`
///
/// Demo / Cloud Agent builds can keep the dead FlutterFlow host and will
/// automatically enable guest login + the local showcase catalog.
class AppEnvironment {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static const bypassAuthFlag = String.fromEnvironment('BYPASS_AUTH');
  static const showcaseDataFlag = String.fromEnvironment('SHOWCASE_DATA');

  static bool get hasLiveSupabaseOverrides =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
