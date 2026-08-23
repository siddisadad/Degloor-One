import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'customer_home_widget.dart' show CustomerHomeWidget;
import 'package:flutter/material.dart';

class CustomerHomeModel extends FlutterFlowModel<CustomerHomeWidget> {
  ///  State fields for stateful widgets in this page.

  Future<List<UserProfile>>? userProfileFuture;
  Future<List<Shop>>? openNowBusinessesFuture;
  Future<List<CatalogProduct>>? recommendedProductsFuture;
  String locationName = 'Degloor, Maharashtra';
  bool openNow = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
