import 'package:degloor_one/core/app_environment.dart';

export 'package:degloor_one/core/app_environment.dart'
    show AppEnvironment, AppFlavor;

/// Guest mode. Defaults to false; enable in dev with --dart-define=BYPASS_AUTH=true
/// Automatically enabled when pointing to the retired FlutterFlow host.
/// Strictly disabled in staging and production.
bool get kBypassAuth =>
    AppEnvironment.allowsDemoExtras &&
    (AppEnvironment.bypassAuth || AppEnvironment.usesDeadFlutterFlowHost);

/// Block sockets and use the local catalog only while the FlutterFlow host
/// still fails DNS. A live health probe turns this off so table reads hit
/// the project.
bool get kShouldBlockSupabaseTraffic =>
    kUsesDeadFlutterFlowHost && !AppEnvironment.flutterFlowHostIsLive;

/// Local Degloor catalog. Defaults to false; enable in dev with --dart-define=SHOWCASE_DATA=true
/// Automatically enabled while the FlutterFlow host is unreachable or retired.
/// Strictly disabled in staging and production.
bool get kUseShowcaseData =>
    AppEnvironment.allowsDemoExtras &&
    (AppEnvironment.useShowcaseData ||
        (kUsesDeadFlutterFlowHost && !AppEnvironment.flutterFlowHostIsLive));

/// True when the compiled URL still points at the FlutterFlow project.
bool get kUsesDeadFlutterFlowHost => AppEnvironment.usesDeadFlutterFlowHost;

AppFlavor get kAppFlavor => AppEnvironment.flavor;
