import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/features/auth/authentication_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await SupaFlow.initialize();
    await FlutterFlowTheme.initialize();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState.instance.initializePersistedState();
  });

  testWidgets('login stays on Welcome back without the server restore banner',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<FFAppState>.value(
        value: FFAppState.instance,
        child: const MaterialApp(
          home: AuthenticationWidget(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(
      find.text(SupabaseConnection.unreachableMessage),
      findsNothing,
    );
    expect(find.textContaining('SUPABASE_URL'), findsNothing);
  });

  testWidgets('sign in does not print skipped-auth debug lines', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final printed = <String>[];
    final previous = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      printed.add(message ?? '');
    };
    try {
      await tester.pumpWidget(
        ChangeNotifierProvider<FFAppState>.value(
          value: FFAppState.instance,
          child: const MaterialApp(
            home: AuthenticationWidget(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.enterText(find.byType(TextField).at(0), 'guest@local');
      await tester.enterText(find.byType(TextField).at(1), 'password');
      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    } finally {
      debugPrint = previous;
    }

    expect(
      printed.where((line) => line.contains('Skipped Auth request')),
      isEmpty,
    );
    expect(
      printed.where(
        (line) => line.contains('FlutterFlow Supabase host is down'),
      ),
      isEmpty,
    );
    expect(
      find.text(SupabaseConnection.guestUnreachableMessage),
      findsOneWidget,
    );
    expect(find.textContaining('SUPABASE_URL'), findsNothing);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });
}
