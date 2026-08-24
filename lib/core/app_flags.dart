import 'package:degloor_one/core/app_environment.dart';

export 'package:degloor_one/core/app_environment.dart'
    show AppEnvironment, AppFlavor;

/// Guest mode. Defaults to false; enable in dev with --dart-define=BYPASS_AUTH=true
/// Automatically enabled when pointing to the retired FlutterFlow host.
bool get kBypassAuth =>
    AppEnvironment.bypassAuth || AppEnvironment.usesDeadFlutterFlowHost;

/// Local Degloor catalog. Defaults to false; enable in dev with --dart-define=SHOWCASE_DATA=true
/// Automatically enabled when pointing to the retired FlutterFlow host.
bool get kUseShowcaseData =>
    AppEnvironment.useShowcaseData || AppEnvironment.usesDeadFlutterFlowHost;

/// True when the compiled URL still points at the deleted FlutterFlow project.
bool get kUsesDeadFlutterFlowHost => AppEnvironment.usesDeadFlutterFlowHost;

AppFlavor get kAppFlavor => AppEnvironment.flavor;
