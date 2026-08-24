import 'dart:async';

import 'package:degloor_one/core/app_environment.dart';
import 'package:degloor_one/data/datasources/bind_address_service.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppEnvironment.debugOverride(
    flavor: AppFlavor.development,
    bypassAuth: true,
    useShowcaseData: true,
  );
  bindAddressService();
  await testMain();
}
