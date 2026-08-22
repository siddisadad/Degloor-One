import 'dart:async';

import 'package:degloor_one/core/app_environment.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppEnvironment.debugOverride(
    flavor: AppFlavor.development,
    bypassAuth: true,
    useShowcaseData: true,
  );
  await testMain();
}
