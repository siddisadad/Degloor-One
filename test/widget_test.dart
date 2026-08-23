import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/core/splash_screen_widget.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await SupaFlow.initialize();
    await FlutterFlowTheme.initialize();
    await FFAppState.instance.initializePersistedState();
  });

  testWidgets('SplashScreen builds successfully smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (context) => FFAppState.instance,
          child: const SplashScreenWidget(),
        ),
      ),
    );

    expect(find.byType(Image), findsWidgets);
    expect(find.text('Everything local, in one app.'), findsOneWidget);
    expect(find.text('Degloor, Maharashtra'), findsOneWidget);
  });
}
