import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'business_catalogue_widget.dart' show BusinessCatalogueWidget;
import 'package:flutter/material.dart';

class BusinessCatalogueModel extends FlutterFlowModel<BusinessCatalogueWidget> {
  final unfocusNode = FocusNode();

  List<CatalogProduct> allProducts = [];
  Map<String, List<CatalogProduct>> groupedProducts = {};
  List<ProductCategory> categories = [];
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
