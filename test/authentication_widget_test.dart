import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/features/auth/authentication_widget.dart';
import 'package:degloor_one/features/auth/signup_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _loginApp({String location = '/authentication'}) {
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: '/authentication',
        name: 'Authentication',
        builder: (_, __) => const AuthenticationWidget(),
      ),
      GoRoute(
        path: '/signUp',
        name: 'SignUp',
        builder: (_, state) => SignUpWidget(
          role: state.uri.queryParameters['role'],
        ),
      ),
      GoRoute(
        path: '/phoneAuth',
        name: 'PhoneAuth',
        builder: (_, __) => const Scaffold(body: Text('Phone auth')),
      ),
      GoRoute(
        path: '/',
        name: 'CustomerHome',
        builder: (_, __) => const Scaffold(body: Text('Customer home')),
      ),
      GoRoute(
        path: '/businessRegistration',
        name: 'BusinessRegistration',
        builder: (context, __) => Scaffold(
          body: Column(
            children: [
              IconButton(
                key: const ValueKey('business-registration-back'),
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.popOrGoNamed('CustomerHome'),
              ),
              const Text('Register Business'),
            ],
          ),
        ),
      ),
      GoRoute(
        path: '/businessDashboard',
        name: 'BusinessDashboard',
        builder: (_, __) => const Scaffold(body: Text('Business dashboard')),
      ),
      GoRoute(
        path: '/initialRedirect',
        name: '_initialize',
        builder: (_, __) => const Scaffold(body: Text('Initialize')),
      ),
    ],
  );
  return ChangeNotifierProvider<FFAppState>.value(
    value: FFAppState.instance,
    child: MaterialApp.router(routerConfig: router),
  );
}

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
    expect(find.text('Continue with Phone'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
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

  testWidgets('login shows Customer and Business tabs', (tester) async {
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

    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Business'), findsOneWidget);
    expect(find.text('Sign in to shop local in Degloor.'), findsOneWidget);
    expect(find.text('Don\'t have an account? '), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Create Account'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('login-tab-business')));
    await tester.pump();

    expect(find.text('Sign in to manage your Degloor shop.'), findsOneWidget);
    expect(find.text('Sign in to shop local in Degloor.'), findsNothing);
    expect(find.text('Don\'t have a shop yet? '), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('login-tab-customer')));
    await tester.pump();

    expect(find.text('Sign in to shop local in Degloor.'), findsOneWidget);
    expect(find.text('Sign in to manage your Degloor shop.'), findsNothing);
    expect(find.text('Don\'t have an account? '), findsOneWidget);
    expect(find.text('Create Account'), findsNothing);
  });

  testWidgets('sign up page shows the customer form', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_loginApp(location: '/signUp'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Welcome back'), findsNothing);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(
      find.text('Create an account to shop local in Degloor.'),
      findsOneWidget,
    );
    expect(find.text('Already have an account? '), findsOneWidget);
    expect(find.text('Create Account'), findsNothing);
    expect(find.text('Continue with Phone'), findsNothing);
    expect(find.text('Continue with Google'), findsNothing);
    expect(find.text('Continue with Apple'), findsNothing);
  });

  testWidgets('business sign up keeps the business tab', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_loginApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byKey(const ValueKey('login-tab-business')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('login-sign-up')));
    await tester.tap(find.byKey(const ValueKey('login-sign-up')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.text('Create an account to list your Degloor shop.'),
      findsOneWidget,
    );
    expect(
      find.text('Create an account to shop local in Degloor.'),
      findsNothing,
    );
  });

  testWidgets('customer guest continues to customer home', (tester) async {
    await tester.pumpWidget(_loginApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.ensureVisible(find.text('Continue as Guest'));
    await tester.tap(find.text('Continue as Guest'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Customer home'), findsOneWidget);
  });

  testWidgets('business guest continues to shop registration', (tester) async {
    await tester.pumpWidget(_loginApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byKey(const ValueKey('login-tab-business')));
    await tester.pump();
    await tester.ensureVisible(find.text('Continue as Guest'));
    await tester.tap(find.text('Continue as Guest'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Register Business'), findsOneWidget);
    expect(find.text('Customer home'), findsNothing);
  });

  testWidgets('business guest can return to the Business login tab',
      (tester) async {
    await tester.pumpWidget(_loginApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byKey(const ValueKey('login-tab-business')));
    await tester.pump();
    await tester.ensureVisible(find.text('Continue as Guest'));
    await tester.tap(find.text('Continue as Guest'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Register Business'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('business-registration-back')));
    await tester.pumpAndSettle();

    expect(find.text('Register Business'), findsNothing);
    expect(find.text('Customer home'), findsNothing);
    expect(find.text('Sign in to manage your Degloor shop.'), findsOneWidget);
  });

  testWidgets('shop registration back without a stack goes home',
      (tester) async {
    await tester.pumpWidget(_loginApp(location: '/businessRegistration'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('business-registration-back')));
    await tester.pumpAndSettle();

    expect(find.text('Customer home'), findsOneWidget);
    expect(find.text('Register Business'), findsNothing);
  });

  test('customer auth continues through initialize', () async {
    final model = AuthenticationModel();
    expect(await model.routeAfterAuth(bypassAuth: false), '_initialize');
    expect(await model.routeAfterAuth(bypassAuth: true), '_initialize');
  });

  test('business bypass auth continues to shop registration', () async {
    final model = AuthenticationModel()..isBusinessOwner = true;
    expect(
      await model.routeAfterAuth(bypassAuth: true),
      'BusinessRegistration',
    );
  });
}
