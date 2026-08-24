import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/guest_auth_user.dart';
import 'auth/password_recovery.dart';
import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/data/datasources/bind_address_service.dart';
import 'package:degloor_one/data/datasources/bind_cart_service.dart';
import 'package:degloor_one/data/datasources/bind_delivery_service.dart';
import 'package:degloor_one/data/datasources/bind_discovery_service.dart';
import 'package:degloor_one/data/datasources/bind_job_service.dart';
import 'package:degloor_one/data/datasources/bind_order_service.dart';
import 'package:degloor_one/data/datasources/bind_shop_service.dart';
import 'package:degloor_one/data/datasources/bind_user_service.dart';
import 'package:degloor_one/shared/app_notification.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:degloor_one/core/web_channel_buffers.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/app_state.dart';
import 'package:provider/provider.dart';

/// The entry point for the DEGLOOR ONE application.
///
/// This function initializes the Flutter binding, configures URL strategies,
/// and initializes essential services like Supabase, Theme, and AppState
/// before launching the app.
void main() async {
  acceptEarlyLifecycleMessages();
  WidgetsFlutterBinding.ensureInitialized();
  releaseHeldBrowserLifecycle();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await SupaFlow.initialize();
  bindAddressService();
  bindUserService();
  bindShopService();
  bindDiscoveryService();
  bindJobService();
  bindCartService();
  bindOrderService();
  bindDeliveryService();

  await FlutterFlowTheme.initialize();

  final appState = FFAppState.instance; // Initialize shared states
  await appState.initializePersistedState();
  if (kBypassAuth) {
    installGuestSession();
  }
  if (kUseShowcaseData && appState.userLocation == null) {
    appState.userLocation = ShowcaseCatalog.degloor;
  }

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: const MyApp(),
  ));
}

/// The root widget of the DEGLOOR ONE application.
///
/// It manages the application's lifecycle, theme mode, and routing.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  /// Returns the current state of [MyApp] from the given [context].
  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  /// The current theme mode of the application.
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  /// Retrieves the URI path for a given [routeMatch] or the current configuration's last match.
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.path;
  }

  /// Returns a list of URI paths representing the current navigation stack.
  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();

  /// A stream of the current authenticated user.
  late Stream<BaseAuthUser> userStream;
  StreamSubscription<List<AppNotification>>? _notificationSubscription;
  StreamSubscription<BaseAuthUser>? _userSubscription;
  StreamSubscription<dynamic>? _jwtSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  void _setupNotificationListener(String userId) {
    _notificationSubscription?.cancel();
    if (userId.isEmpty) return;

    _notificationSubscription = NotificationService.instance
        .watchForUser(userId)
        .listen((notifications) {
      if (notifications.isEmpty) return;

      // Get the latest notification
      final latest = notifications.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final notification = latest.first;

      // Only show if it's brand new (e.g. created in the last 10 seconds)
      final now = DateTime.now();
      if (now.difference(notification.createdAt).inSeconds < 10 &&
          !notification.isRead) {
        _showGlobalNotification(notification);
      }
    });
  }

  void _showGlobalNotification(AppNotification notification) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(notification.message),
          ],
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            _router.pushNamed('Notifications');
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    if (kBypassAuth) {
      installGuestSession();
      _appStateNotifier.update(currentUser!);
    }
    _router = createRouter(_appStateNotifier);
    userStream = degloorOneSupabaseUserStream();
    _userSubscription = userStream.listen((user) {
      _appStateNotifier.update(user);
      if (user.loggedIn && user.uid != null && user is! GuestAuthUser) {
        _setupNotificationListener(user.uid!);
      } else {
        _notificationSubscription?.cancel();
      }
    });
    _jwtSubscription = jwtTokenStream.listen((_) {});
    _authSubscription =
        SupaFlow.client.auth.onAuthStateChange.listen((authState) {
      if (authState.event == AuthChangeEvent.passwordRecovery && mounted) {
        PasswordRecovery.pending.value = true;
        _router.goNamed('ResetPassword');
      }
    });
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _userSubscription?.cancel();
    _jwtSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Updates the application's theme mode and persists the choice.
  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<FFAppState>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'DEGLOOR ONE',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('mr', ''),
        Locale('hi', ''),
      ],
      locale: Locale(appState.locale),
      theme: DegloorTheme.lightTheme,
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
