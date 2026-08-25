import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/auth/password_recovery.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/core/app_flags.dart';
import 'package:degloor_one/features/auth/initial_redirect_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:degloor_one/shared/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _route({
  bool passwordRecoveryPending = false,
  bool loggedIn = true,
  bool bypassAuth = true,
  String? role = 'customer',
  String userId = 'user-1',
  bool hasShop = false,
  bool hasProvider = false,
}) {
  return resolveStartRoute(
    passwordRecoveryPending: passwordRecoveryPending,
    loggedIn: loggedIn,
    bypassAuth: bypassAuth,
    role: role,
    userId: userId,
    hasOwnedShop: (_) async => hasShop,
    hasProviderProfile: (_) async => hasProvider,
  );
}

Widget _redirectApp() {
  final router = GoRouter(
    initialLocation: '/initialRedirect',
    routes: [
      GoRoute(
        path: '/initialRedirect',
        name: 'InitialRedirect',
        builder: (_, __) => const InitialRedirectWidget(),
      ),
      GoRoute(
        path: '/customerHome',
        name: 'CustomerHome',
        builder: (_, __) => const Scaffold(body: Text('Customer home')),
      ),
      GoRoute(
        path: '/businessDashboard',
        name: 'BusinessDashboard',
        builder: (_, __) => const Scaffold(body: Text('Business dashboard')),
      ),
      GoRoute(
        path: '/businessRegistration',
        name: 'BusinessRegistration',
        builder: (_, __) => const Scaffold(body: Text('Register Business')),
      ),
      GoRoute(
        path: '/manageServiceRequests',
        name: 'ManageServiceRequests',
        builder: (_, __) => const Scaffold(body: Text('Service requests')),
      ),
      GoRoute(
        path: '/serviceProviderRegistration',
        name: 'ServiceProviderRegistration',
        builder: (_, __) => const Scaffold(body: Text('Join as a Provider')),
      ),
      GoRoute(
        path: '/adminControlPanel',
        name: 'AdminControlPanel',
        builder: (_, __) => const Scaffold(body: Text('Admin')),
      ),
      GoRoute(
        path: '/authentication',
        name: 'Authentication',
        builder: (_, __) => const Scaffold(body: Text('Welcome back')),
      ),
      GoRoute(
        path: '/resetPassword',
        name: 'ResetPassword',
        builder: (_, __) => const Scaffold(body: Text('Reset password')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await FlutterFlowTheme.initialize();
  });

  setUp(() {
    PasswordRecovery.pending.value = false;
    ShowcaseCatalog.reset();
    installGuestSession();
  });

  test('password recovery wins over role', () async {
    expect(
      await _route(
        passwordRecoveryPending: true,
        role: 'business_owner',
        hasShop: true,
      ),
      'ResetPassword',
    );
  });

  test('signed-out bypass still opens customer home', () async {
    expect(
      await _route(loggedIn: false, bypassAuth: true),
      'CustomerHome',
    );
  });

  test('signed-out live session opens login', () async {
    expect(
      await _route(loggedIn: false, bypassAuth: false),
      'Authentication',
    );
  });

  test('customer and unknown roles open customer home', () async {
    expect(await _route(role: 'customer'), 'CustomerHome');
    expect(await _route(role: null), 'CustomerHome');
  });

  test('shop owner opens the dashboard when a shop exists', () async {
    expect(
      await _route(role: 'business_owner', hasShop: true),
      'BusinessDashboard',
    );
  });

  test('shop owner without a shop opens registration', () async {
    expect(
      await _route(role: 'business_owner', hasShop: false),
      'BusinessRegistration',
    );
  });

  test('service provider opens request inbox when a profile exists', () async {
    expect(
      await _route(role: 'service_provider', hasProvider: true),
      'ManageServiceRequests',
    );
  });

  test('service provider without a profile opens join', () async {
    expect(
      await _route(role: 'service_provider', hasProvider: false),
      'ServiceProviderRegistration',
    );
  });

  test('admin opens the control panel', () async {
    expect(await _route(role: 'admin'), 'AdminControlPanel');
  });

  testWidgets('guest customer start still goes home', (tester) async {
    expect(kBypassAuth, isTrue);
    installGuestSession();

    await tester.pumpWidget(_redirectApp());
    await tester.pumpAndSettle();

    expect(find.text('Customer home'), findsOneWidget);
    expect(find.text('Business dashboard'), findsNothing);
  });

  testWidgets('guest shop owner start opens the showcase shop dashboard',
      (tester) async {
    installGuestSession();
    promoteGuestRole(UserRole.businessOwner);

    await tester.pumpWidget(_redirectApp());
    await tester.pumpAndSettle();

    expect(find.text('Business dashboard'), findsOneWidget);
    expect(find.text('Customer home'), findsNothing);
  });

  testWidgets('guest provider start opens join when they have no profile',
      (tester) async {
    installGuestSession();
    promoteGuestRole(UserRole.serviceProvider);

    await tester.pumpWidget(_redirectApp());
    await tester.pumpAndSettle();

    expect(find.text('Join as a Provider'), findsOneWidget);
    expect(find.text('Customer home'), findsNothing);
  });
}
