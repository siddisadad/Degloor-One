import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/app_environment.dart';

void main() {
  test('test harness enables explicit development demo extras', () {
    expect(AppEnvironment.flavor, AppFlavor.development);
    expect(AppEnvironment.bypassAuth, isTrue);
    expect(AppEnvironment.useShowcaseData, isTrue);
    expect(kBypassAuth, AppEnvironment.bypassAuth);
    expect(kUseShowcaseData, AppEnvironment.useShowcaseData);
    expect(kAppFlavor, AppFlavor.development);
  });

  test('compiled defaults stay production-safe without overrides', () {
    AppEnvironment.debugReset();
    addTearDown(() {
      AppEnvironment.debugOverride(
        flavor: AppFlavor.development,
        bypassAuth: true,
        useShowcaseData: true,
      );
    });

    expect(AppEnvironment.usesDeadFlutterFlowHost, isTrue);
    expect(AppEnvironment.flavor, AppFlavor.production);
    expect(AppEnvironment.bypassAuth, isFalse);
    expect(AppEnvironment.useShowcaseData, isFalse);
    expect(AppEnvironment.hasLiveSupabaseOverrides, isFalse);
    expect(kSupabaseUrl, AppEnvironment.supabaseUrl);
    expect(kSupabaseAnonKey, AppEnvironment.supabaseAnonKey);
  });

  test('parseFlavor defaults unknown values to production', () {
    expect(AppEnvironment.parseFlavor(''), AppFlavor.production);
    expect(AppEnvironment.parseFlavor('prod'), AppFlavor.production);
    expect(AppEnvironment.parseFlavor('staging'), AppFlavor.staging);
    expect(AppEnvironment.parseFlavor('demo'), AppFlavor.development);
    expect(AppEnvironment.parseFlavor('development'), AppFlavor.development);
  });

  test('dead host never enables demo extras by itself', () {
    expect(
      AppEnvironment.resolveDemoFlag(allowsDemo: false, flag: 'true'),
      isFalse,
    );
    expect(
      AppEnvironment.resolveDemoFlag(allowsDemo: true, flag: ''),
      isFalse,
    );
    expect(
      AppEnvironment.resolveDemoFlag(allowsDemo: true, flag: 'true'),
      isTrue,
    );
  });
}
