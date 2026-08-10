import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'manage_catalogue_widget.dart' show ManageCatalogueWidget;
import 'package:flutter/material.dart';

class ManageCatalogueModel extends FlutterFlowModel<ManageCatalogueWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for productName widget.
  FocusNode? productNameFocusNode;
  TextEditingController? productNameTextController;
  String? Function(BuildContext, String?)? productNameTextControllerValidator;
  // State field(s) for productPrice widget.
  FocusNode? productPriceFocusNode;
  TextEditingController? productPriceTextController;
  String? Function(BuildContext, String?)? productPriceTextControllerValidator;
  // State field(s) for productCategory widget.
  FocusNode? productCategoryFocusNode;
  TextEditingController? productCategoryTextController;
  String? Function(BuildContext, String?)?
      productCategoryTextControllerValidator;

  // State field(s) for stockQuantity widget.
  FocusNode? stockQuantityFocusNode;
  TextEditingController? stockQuantityTextController;
  String? Function(BuildContext, String?)? stockQuantityTextControllerValidator;

  bool trackInventory = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    productNameFocusNode?.dispose();
    productNameTextController?.dispose();

    productPriceFocusNode?.dispose();
    productPriceTextController?.dispose();

    productCategoryFocusNode?.dispose();
    productCategoryTextController?.dispose();

    stockQuantityFocusNode?.dispose();
    stockQuantityTextController?.dispose();
  }
}
