import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/slider/slider_widget.dart';
import 'package:degloor_one/components/switch_component/switch_component_widget.dart';
import 'package:degloor_one/components/text_field/text_field_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'edit_business_profile_widget.dart' show EditBusinessProfileWidget;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditBusinessProfileModel extends FlutterFlowModel<EditBusinessProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for TextField (Name).
  late TextFieldModel textFieldModel1;
  // Model for TextField (Owner).
  late TextFieldModel textFieldModel2;
  // Model for TextField (Description).
  late TextFieldModel textFieldModel3;
  // Model for TextField (Phone).
  late TextFieldModel textFieldModel4;
  // Model for TextField (WhatsApp).
  late TextFieldModel textFieldModel5;
  // Model for Switch.
  late SwitchComponentModel switchModel;
  // Model for TextField (Address).
  late TextFieldModel textFieldModel6;
  // Model for Slider.
  late SliderModel sliderModel;
  // Model for Button.
  late ButtonModel buttonModel;

  String? imageUrl;
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
      imageUrl = await BusinessService.instance.uploadPublicImage(
        folder: 'businesses',
        businessId: businessId,
        bytes: bytes,
      );
    } finally {
      isUploading = false;
      onBusyChanged?.call();
    }
  }

  @override
  void initState(BuildContext context) {
    textFieldModel1 = createModel(context, () => TextFieldModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    textFieldModel3 = createModel(context, () => TextFieldModel());
    textFieldModel4 = createModel(context, () => TextFieldModel());
    textFieldModel5 = createModel(context, () => TextFieldModel());
    switchModel = createModel(context, () => SwitchComponentModel());
    textFieldModel6 = createModel(context, () => TextFieldModel());
    sliderModel = createModel(context, () => SliderModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    textFieldModel1.dispose();
    textFieldModel2.dispose();
    textFieldModel3.dispose();
    textFieldModel4.dispose();
    textFieldModel5.dispose();
    switchModel.dispose();
    textFieldModel6.dispose();
    sliderModel.dispose();
    buttonModel.dispose();
  }
}
