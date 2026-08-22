import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:degloor_one/auth/base_auth_user_provider.dart';

import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => const InitialRedirectWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => const InitialRedirectWidget(),
        ),
        FFRoute(
          name: SplashScreenWidget.routeName,
          path: SplashScreenWidget.routePath,
          builder: (context, params) => const SplashScreenWidget(),
        ),
        FFRoute(
          name: AuthenticationWidget.routeName,
          path: AuthenticationWidget.routePath,
          builder: (context, params) => const AuthenticationWidget(),
        ),
        FFRoute(
          name: PhoneAuthWidget.routeName,
          path: PhoneAuthWidget.routePath,
          builder: (context, params) => const PhoneAuthWidget(),
        ),
        FFRoute(
          name: ForgotPasswordWidget.routeName,
          path: ForgotPasswordWidget.routePath,
          builder: (context, params) => ForgotPasswordWidget(
            email: params.getParam<String>('email', ParamType.string),
          ),
        ),
        FFRoute(
          name: ResetPasswordWidget.routeName,
          path: ResetPasswordWidget.routePath,
          builder: (context, params) => const ResetPasswordWidget(),
        ),
        FFRoute(
          name: OtpVerificationWidget.routeName,
          path: OtpVerificationWidget.routePath,
          builder: (context, params) => OtpVerificationWidget(
            phone: params.getParam<String>('phone', ParamType.string)!,
          ),
        ),
        FFRoute(
          name: InitialRedirectWidget.routeName,
          path: InitialRedirectWidget.routePath,
          builder: (context, params) => const InitialRedirectWidget(),
        ),
        FFRoute(
          name: CustomerHomeWidget.routeName,
          path: CustomerHomeWidget.routePath,
          builder: (context, params) => const CustomerHomeWidget(),
        ),
        FFRoute(
          name: LocationRadiusSelectorWidget.routeName,
          path: LocationRadiusSelectorWidget.routePath,
          builder: (context, params) => const LocationRadiusSelectorWidget(),
        ),
        FFRoute(
          name: SearchResultsWidget.routeName,
          path: SearchResultsWidget.routePath,
          builder: (context, params) => SearchResultsWidget(
            searchTerm: params.getParam<String>('searchTerm', ParamType.string),
            categoryId: params.getParam<String>('categoryId', ParamType.string),
            openNow: params.getParam<bool>('openNow', ParamType.bool),
          ),
        ),
        FFRoute(
          name: CategoriesWidget.routeName,
          path: CategoriesWidget.routePath,
          builder: (context, params) => const CategoriesWidget(),
        ),
        FFRoute(
          name: BusinessProfileWidget.routeName,
          path: BusinessProfileWidget.routePath,
          builder: (context, params) => BusinessProfileWidget(
            businessId: params.getParam<String>('businessId', ParamType.string),
          ),
        ),
        FFRoute(
          name: BusinessCatalogueWidget.routeName,
          path: BusinessCatalogueWidget.routePath,
          builder: (context, params) => BusinessCatalogueWidget(
            businessId: params.getParam<String>('businessId', ParamType.string)!,
          ),
        ),
        FFRoute(
          name: BusinessRegistrationWidget.routeName,
          path: BusinessRegistrationWidget.routePath,
          builder: (context, params) => const BusinessRegistrationWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: BusinessDashboardWidget.routeName,
          path: BusinessDashboardWidget.routePath,
          builder: (context, params) => const BusinessDashboardWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: BusinessAnalyticsWidget.routeName,
          path: BusinessAnalyticsWidget.routePath,
          builder: (context, params) => BusinessAnalyticsWidget(
            businessId: params.getParam<String>('businessId', ParamType.string)!,
          ),
          requireAuth: true,
        ),
        FFRoute(
          name: AdminControlPanelWidget.routeName,
          path: AdminControlPanelWidget.routePath,
          builder: (context, params) => const AdminControlPanelWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: UserProfileReportsWidget.routeName,
          path: UserProfileReportsWidget.routePath,
          builder: (context, params) => const UserProfileReportsWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: CartWidget.routeName,
          path: CartWidget.routePath,
          builder: (context, params) => const CartWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: ManageCatalogueWidget.routeName,
          path: ManageCatalogueWidget.routePath,
          builder: (context, params) => const ManageCatalogueWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: ManageOrdersWidget.routeName,
          path: ManageOrdersWidget.routePath,
          builder: (context, params) => const ManageOrdersWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: CustomerOrdersWidget.routeName,
          path: CustomerOrdersWidget.routePath,
          builder: (context, params) => const CustomerOrdersWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: ManageHoursWidget.routeName,
          path: ManageHoursWidget.routePath,
          builder: (context, params) => const ManageHoursWidget(),
          requireAuth: true,
        ),
        /* Commented out Phase 2+ routes
        FFRoute(
          name: DeliveryDashboardWidget.routeName,
          path: DeliveryDashboardWidget.routePath,
          builder: (context, params) => DeliveryDashboardWidget(),
        ),
        */
        FFRoute(
          name: NotificationsWidget.routeName,
          path: NotificationsWidget.routePath,
          builder: (context, params) => const NotificationsWidget(),
        ),
        FFRoute(
          name: AddressListWidget.routeName,
          path: AddressListWidget.routePath,
          builder: (context, params) => const AddressListWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: AddAddressWidget.routeName,
          path: AddAddressWidget.routePath,
          builder: (context, params) => const AddAddressWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: OrderTrackingWidget.routeName,
          path: OrderTrackingWidget.routePath,
          builder: (context, params) => OrderTrackingWidget(
            orderId: params.getParam<String>('orderId', ParamType.string)!,
          ),
          requireAuth: true,
        ),
        FFRoute(
          name: OrderSuccessWidget.routeName,
          path: OrderSuccessWidget.routePath,
          builder: (context, params) => OrderSuccessWidget(
            orderId: params.getParam<String>('orderId', ParamType.string),
          ),
          requireAuth: true,
        ),
        FFRoute(
          name: EditBusinessProfileWidget.routeName,
          path: EditBusinessProfileWidget.routePath,
          builder: (context, params) => EditBusinessProfileWidget(
            business: params.getParam<BusinessesRow>('business', ParamType.supabaseRow)!,
          ),
          requireAuth: true,
        ),
        FFRoute(
          name: JobsMarketplaceWidget.routeName,
          path: JobsMarketplaceWidget.routePath,
          builder: (context, params) => const JobsMarketplaceWidget(),
        ),
        FFRoute(
          name: ManageJobsWidget.routeName,
          path: ManageJobsWidget.routePath,
          builder: (context, params) => const ManageJobsWidget(),
          requireAuth: true,
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/authentication';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => const TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
