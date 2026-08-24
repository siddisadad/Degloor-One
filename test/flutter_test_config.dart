import 'dart:async';

import 'package:degloor_one/core/app_environment.dart';
import 'package:degloor_one/data/datasources/bind_address_service.dart';
import 'package:degloor_one/data/datasources/bind_cart_service.dart';
import 'package:degloor_one/data/datasources/bind_delivery_service.dart';
import 'package:degloor_one/data/datasources/bind_discovery_service.dart';
import 'package:degloor_one/data/datasources/bind_job_service.dart';
import 'package:degloor_one/data/datasources/bind_order_service.dart';
import 'package:degloor_one/data/datasources/bind_shop_service.dart';
import 'package:degloor_one/data/datasources/bind_user_service.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppEnvironment.debugOverride(
    flavor: AppFlavor.development,
    bypassAuth: true,
    useShowcaseData: true,
  );
  bindAddressService();
  bindUserService();
  bindShopService();
  bindDiscoveryService();
  bindJobService();
  bindCartService();
  bindOrderService();
  bindDeliveryService();
  await testMain();
}
