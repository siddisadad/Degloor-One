import 'package:degloor_one/core/app_flags.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('strictly disables demo flags in production flavor', () {
    AppEnvironment.debugOverride(flavor: AppFlavor.production);
    addTearDown(AppEnvironment.debugReset);

    expect(AppEnvironment.isProduction, isTrue);
    expect(AppEnvironment.bypassAuth, isFalse);
    expect(AppEnvironment.useShowcaseData, isFalse);
    expect(kUseShowcaseData, isFalse);
    expect(kBypassAuth, isFalse);
  });

  test('strictly disables demo flags in staging flavor', () {
    AppEnvironment.debugOverride(flavor: AppFlavor.staging);
    addTearDown(AppEnvironment.debugReset);

    expect(AppEnvironment.isProduction, isFalse);
    expect(AppEnvironment.bypassAuth, isFalse);
    expect(AppEnvironment.useShowcaseData, isFalse);
    expect(kUseShowcaseData, isFalse);
    expect(kBypassAuth, isFalse);
  });

  test('allows demo flags ONLY in development flavor', () {
    AppEnvironment.debugOverride(
      flavor: AppFlavor.development,
      bypassAuth: true,
      useShowcaseData: true,
    );
    addTearDown(AppEnvironment.debugReset);

    expect(AppEnvironment.isProduction, isFalse);
    expect(AppEnvironment.allowsDemoExtras, isTrue);
    expect(AppEnvironment.bypassAuth, isTrue);
    expect(AppEnvironment.useShowcaseData, isTrue);
    expect(kUseShowcaseData, isTrue);
  });
}
