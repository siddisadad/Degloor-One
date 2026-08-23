import 'package:degloor_one/core/app_environment.dart';

export 'package:degloor_one/core/app_environment.dart'
    show AppEnvironment, AppFlavor;

/// Guest mode. Forced on while Degloor ships the local catalog.
bool get kBypassAuth => true;

/// Local Degloor catalog. Forced on while live Supabase is paused.
bool get kUseShowcaseData => true;

/// True when the compiled URL still points at the deleted FlutterFlow project.
bool get kUsesDeadFlutterFlowHost => AppEnvironment.usesDeadFlutterFlowHost;

AppFlavor get kAppFlavor => AppEnvironment.flavor;
