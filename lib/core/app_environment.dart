/// Dart-define switches used by DEGLOOR ONE.
///
/// Production builds must pass a live project:
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
/// `--dart-define=BYPASS_AUTH=false --dart-define=SHOWCASE_DATA=false`
///
/// Demo / Cloud Agent builds can keep the dead FlutterFlow host and will
/// automatically enable guest login + the local showcase catalog.
class AppEnvironment {
  static const deadFlutterFlowHost = 'uhaibenopzyzzuqjawlb.supabase.co';
  static const defaultSupabaseUrl = 'https://$deadFlutterFlowHost';
  static const defaultSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVoYWliZW5vcHp5enp1cWphd2xiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYzMDM3NDksImV4cCI6MjEwMTg3OTc0OX0.bb6O2gBGsqtotv1AarJIVo7m1HHkNf5HM7eW3LD0O5s';

  static const supabaseUrlOverride = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const supabaseAnonKeyOverride = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static const bypassAuthFlag = String.fromEnvironment('BYPASS_AUTH');
  static const showcaseDataFlag = String.fromEnvironment('SHOWCASE_DATA');

  static String get supabaseUrl =>
      supabaseUrlOverride.isNotEmpty ? supabaseUrlOverride : defaultSupabaseUrl;

  static String get supabaseAnonKey => supabaseAnonKeyOverride.isNotEmpty
      ? supabaseAnonKeyOverride
      : defaultSupabaseAnonKey;

  static bool get usesDeadFlutterFlowHost {
    final host = Uri.tryParse(supabaseUrl)?.host ?? '';
    return host == deadFlutterFlowHost;
  }

  /// Guest session when Auth cannot reach a live project.
  static bool get bypassAuth {
    if (bypassAuthFlag == 'true') return true;
    if (bypassAuthFlag == 'false') return false;
    return usesDeadFlutterFlowHost;
  }

  /// Local Degloor catalog while PostgREST is down.
  static bool get useShowcaseData {
    if (showcaseDataFlag == 'true') return true;
    if (showcaseDataFlag == 'false') return false;
    return usesDeadFlutterFlowHost;
  }

  static bool get hasLiveSupabaseOverrides =>
      supabaseUrlOverride.isNotEmpty && supabaseAnonKeyOverride.isNotEmpty;
}
