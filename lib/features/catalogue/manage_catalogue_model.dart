import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'manage_catalogue_widget.dart' show ManageCatalogueWidget;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  String? uploadedImageUrl;
  bool isUploading = false;

  /// Gallery pick plus public upload. The widget only shows the tile.
  Future<void> pickPhoto({
    required String userId,
    required String businessId,
    VoidCallback? onBusyChanged,
  }) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;
    await uploadPhotoBytes(
      userId: userId,
      businessId: businessId,
      bytes: await image.readAsBytes(),
      onBusyChanged: onBusyChanged,
    );
  }

  Future<void> uploadPhotoBytes({
    required String userId,
    required String businessId,
    required List<int> bytes,
    VoidCallback? onBusyChanged,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Please login to update the shop');
    }
    if (businessId.isEmpty) {
      throw Exception('Please choose a shop');
    }
    isUploading = true;
    onBusyChanged?.call();
    try {
      uploadedImageUrl = await BusinessService.instance.uploadPublicImage(
        folder: 'products',
        businessId: businessId,
        bytes: bytes,
      );
    } finally {
      isUploading = false;
      onBusyChanged?.call();
    }
  }

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
