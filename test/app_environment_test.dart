import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/app_environment.dart';

void main() {
  test('default compile uses the dead FlutterFlow host and guest extras', () {
    expect(AppEnvironment.usesDeadFlutterFlowHost, isTrue);
    expect(AppEnvironment.bypassAuth, isTrue);
    expect(AppEnvironment.useShowcaseData, isTrue);
    expect(AppEnvironment.hasLiveSupabaseOverrides, isFalse);
    expect(kSupabaseUrl, AppEnvironment.supabaseUrl);
    expect(kSupabaseAnonKey, AppEnvironment.supabaseAnonKey);
    expect(kBypassAuth, AppEnvironment.bypassAuth);
    expect(kUseShowcaseData, AppEnvironment.useShowcaseData);
    expect(kUsesDeadFlutterFlowHost, isTrue);
  });
}
