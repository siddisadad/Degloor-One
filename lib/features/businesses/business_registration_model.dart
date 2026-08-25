import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/section_header/section_header_widget.dart';
import 'package:degloor_one/components/slider/slider_widget.dart';
import 'package:degloor_one/components/switch_component/switch_component_widget.dart';
import 'package:degloor_one/components/text_field/text_field_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_google_map.dart' hide LatLng;
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/form_field_controller.dart';
import 'package:degloor_one/index.dart';
import 'package:degloor_one/shared/discovery_radius.dart';
import 'package:degloor_one/shared/shop_draft.dart';
import 'business_registration_widget.dart' show BusinessRegistrationWidget;
import 'package:flutter/material.dart';

class BusinessRegistrationModel
    extends FlutterFlowModel<BusinessRegistrationWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SectionHeader.
  late SectionHeaderModel sectionHeaderModel1;
  // Model for TextField.
  late TextFieldModel textFieldModel1;
  // Model for TextField.
  late TextFieldModel textFieldModel2;
  // State field(s) for Dropdown widget.
  String? dropdownValue;
  FormFieldController<String>? dropdownValueController;
  // Model for TextField.
  late TextFieldModel textFieldModel3;
  // Model for SectionHeader.
  late SectionHeaderModel sectionHeaderModel2;
  // Model for TextField.
  late TextFieldModel textFieldModel4;
  // Model for TextField.
  late TextFieldModel textFieldModel5;
  // Model for Switch.
  late SwitchComponentModel switchModel;
  // Model for SectionHeader.
  late SectionHeaderModel sectionHeaderModel3;
  // Model for TextField.
  late TextFieldModel textFieldModel6;
  // Model for TextField.
  late TextFieldModel textFieldModel7;
  // Model for TextField.
  late TextFieldModel textFieldModel8;
  // State field(s) for Map Google Map widget.
  LatLng mapGoogleMapsCenter = const LatLng(18.5522, 77.5844);
  final mapGoogleMapsController = Completer<GoogleMapController>();
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for SectionHeader.
  late SectionHeaderModel sectionHeaderModel4;
  // Model for Slider.
  late SliderModel sliderModel;
  // Model for SectionHeader.
  late SectionHeaderModel sectionHeaderModel5;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    sectionHeaderModel1 = createModel(context, () => SectionHeaderModel());
    textFieldModel1 = createModel(context, () => TextFieldModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    textFieldModel3 = createModel(context, () => TextFieldModel());
    sectionHeaderModel2 = createModel(context, () => SectionHeaderModel());
    textFieldModel4 = createModel(context, () => TextFieldModel());
    textFieldModel5 = createModel(context, () => TextFieldModel());
    switchModel = createModel(context, () => SwitchComponentModel());
    sectionHeaderModel3 = createModel(context, () => SectionHeaderModel());
    textFieldModel6 = createModel(context, () => TextFieldModel());
    textFieldModel7 = createModel(context, () => TextFieldModel());
    textFieldModel8 = createModel(context, () => TextFieldModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    sectionHeaderModel4 = createModel(context, () => SectionHeaderModel());
    sliderModel = createModel(context, () => SliderModel());
    sectionHeaderModel5 = createModel(context, () => SectionHeaderModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  /// Register the shop and send the owner to the dashboard.
  ///
  /// The widget only collects the form; insert and role promote stay here.
  Future<String> submit({required String userId}) async {
    if (userId.isEmpty) {
      throw Exception('Please login to register a business');
    }
    final name = textFieldModel1.inputTextController?.text ?? '';
    final owner = textFieldModel2.inputTextController?.text ?? '';
    final phone = textFieldModel4.inputTextController?.text ?? '';
    final sliderVal = sliderModel.sliderValue ??
        sliderPercentFromRadius(kDefaultDiscoveryRadiusKm);
    final sameWhatsapp = switchModel.switchValue ?? true;
    final whatsapp = sameWhatsapp
        ? phone
        : textFieldModel5.inputTextController?.text;
    await BusinessService.instance.register(
      userId: userId,
      draft: ShopDraft.fromRegister(
        name: name,
        ownerName: owner,
        phone: phone,
        categoryId: dropdownValue ?? '',
        latitude: mapGoogleMapsCenter.latitude,
        longitude: mapGoogleMapsCenter.longitude,
        description: textFieldModel3.inputTextController?.text ?? '',
        whatsappNumber: whatsapp,
        addressText:
            '${textFieldModel6.inputTextController?.text ?? ''}, ${textFieldModel8.inputTextController?.text ?? ''}, ${textFieldModel7.inputTextController?.text ?? 'Degloor'}',
        discoveryRadius: radiusFromSliderPercent(sliderVal),
      ),
    );
    await authManager.refreshUser();
    return 'BusinessDashboard';
  }

  @override
  void dispose() {
    sectionHeaderModel1.dispose();
    textFieldModel1.dispose();
    textFieldModel2.dispose();
    textFieldModel3.dispose();
    sectionHeaderModel2.dispose();
    textFieldModel4.dispose();
    textFieldModel5.dispose();
    switchModel.dispose();
    sectionHeaderModel3.dispose();
    textFieldModel6.dispose();
    textFieldModel7.dispose();
    textFieldModel8.dispose();
    buttonModel1.dispose();
    sectionHeaderModel4.dispose();
    sliderModel.dispose();
    sectionHeaderModel5.dispose();
    buttonModel2.dispose();
  }
}
