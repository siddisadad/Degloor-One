import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'business_catalogue_widget.dart' show BusinessCatalogueWidget;
import 'package:flutter/material.dart';

class BusinessCatalogueModel extends FlutterFlowModel<BusinessCatalogueWidget> {
  final unfocusNode = FocusNode();

  List<ProductsRow> allProducts = [];
  Map<String, List<ProductsRow>> groupedProducts = {};
  List<ProductCategoriesRow> categories = [];
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
