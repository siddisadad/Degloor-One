import 'package:flutter/foundation.dart';

/// Explicit app flavors. Default is production-safe.
enum AppFlavor {
  development,
  staging,
  production,
}

/// Dart-define switches used by DEGLOOR ONE.
///
/// Production / store builds:
/// `--dart-define=APP_ENV=production`
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
///
/// Demo extras are **never** inferred from a dead or unreachable host.
/// They require an explicit development flavor **and** flags:
/// `--dart-define=APP_ENV=development --dart-define=BYPASS_AUTH=true --dart-define=SHOWCASE_DATA=true`
class AppEnvironment {
  static const deadFlutterFlowHost = 'uhaibenopzyzzuqjawlb.supabase.co';
  static const defaultSupabaseUrl = 'https://$deadFlutterFlowHost';

  /// Public anon key for the retired FlutterFlow project only. Production
  /// builds must pass `SUPABASE_ANON_KEY`. This value is not a service role.
  static const defaultSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVoYWliZW5vcHp5enp1cWphd2xiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYzMDM3NDksImV4cCI6MjEwMTg3OTc0OX0.bb6O2gBGsqtotv1AarJIVo7m1HHkNf5HM7eW3LD0O5s';

  static const supabaseUrlOverride = String.fromEnvironment(
    'SUPABASE_URL',
  );
  static const supabaseAnonKeyOverride = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const envFlag = String.fromEnvironment('APP_ENV');
  static const bypassAuthFlag = String.fromEnvironment('BYPASS_AUTH');
  static const showcaseDataFlag = String.fromEnvironment('SHOWCASE_DATA');

  static AppFlavor? _flavorOverride;
  static bool? _bypassOverride;
  static bool? _showcaseOverride;

  static String get supabaseUrl =>
      supabaseUrlOverride.isNotEmpty ? supabaseUrlOverride : defaultSupabaseUrl;

  static String get supabaseAnonKey => supabaseAnonKeyOverride.isNotEmpty
      ? supabaseAnonKeyOverride
      : defaultSupabaseAnonKey;

  static bool get usesDeadFlutterFlowHost {
    final host = Uri.tryParse(supabaseUrl)?.host ?? '';
    return host == deadFlutterFlowHost;
  }

  static AppFlavor get flavor => _flavorOverride ?? parseFlavor(envFlag);

  static bool get allowsDemoExtras => flavor == AppFlavor.development;

  /// Guest session. Staging/production never enable this, even on a dead host.
  static bool get bypassAuth {
    if (_bypassOverride != null) return _bypassOverride!;
    return resolveDemoFlag(
      allowsDemo: allowsDemoExtras,
      flag: bypassAuthFlag,
    );
  }

  /// Local Degloor catalog. Staging/production never enable this.
  static bool get useShowcaseData {
    if (_showcaseOverride != null) return _showcaseOverride!;
    return resolveDemoFlag(
      allowsDemo: allowsDemoExtras,
      flag: showcaseDataFlag,
    );
  }

  static bool get hasLiveSupabaseOverrides =>
      supabaseUrlOverride.isNotEmpty && supabaseAnonKeyOverride.isNotEmpty;

  static bool get isProduction => flavor == AppFlavor.production;

  /// Unset / unknown values default to production so store builds stay closed.
  static AppFlavor parseFlavor(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'development':
      case 'dev':
      case 'demo':
        return AppFlavor.development;
      case 'staging':
      case 'stage':
        return AppFlavor.staging;
      case 'production':
      case 'prod':
      default:
        return AppFlavor.production;
    }
  }

  /// Demo extras require an explicit `true` flag inside a development flavor.
  /// A dead Supabase host never flips this on by itself.
  static bool resolveDemoFlag({
    required bool allowsDemo,
    required String flag,
  }) {
    if (!allowsDemo) return false;
    return flag == 'true';
  }

  @visibleForTesting
  static void debugOverride({
    AppFlavor? flavor,
    bool? bypassAuth,
    bool? useShowcaseData,
  }) {
    _flavorOverride = flavor;
    _bypassOverride = bypassAuth;
    _showcaseOverride = useShowcaseData;
  }

  @visibleForTesting
  static void debugReset() {
    _flavorOverride = null;
    _bypassOverride = null;
    _showcaseOverride = null;
  }
}
