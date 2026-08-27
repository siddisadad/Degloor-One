import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/discovery_service.dart';
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
import 'package:degloor_one/shared/city.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'package:degloor_one/shared/shop_draft.dart';
import 'business_registration_widget.dart' show BusinessRegistrationWidget;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Photo tiles on the registration form. Upload stays on the model.
enum RegistrationPhotoSlot { storeFront, interior, registrationDoc }

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
  // State field(s) for Dropdown widget.
  String? cityValue;
  FormFieldController<String>? cityValueController;
  // Model for TextField.
  late TextFieldModel textFieldModel8;
  // Model for TextField.
  late TextFieldModel textFieldModel9;
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

  bool nameError = false;
  bool ownerError = false;
  bool categoryError = false;
  bool phoneError = false;
  bool addressError = false;
  bool areaError = false;

  String? storeFrontUrl;
  String? interiorUrl;
  String? registrationDocUrl;
  RegistrationPhotoSlot? uploadingSlot;
  List<ShopCategory> categories = [];
  List<City> cities = [];
  bool categoriesLoading = false;
  bool citiesLoading = false;

  String? photoUrl(RegistrationPhotoSlot slot) {
    switch (slot) {
      case RegistrationPhotoSlot.storeFront:
        return storeFrontUrl;
      case RegistrationPhotoSlot.interior:
        return interiorUrl;
      case RegistrationPhotoSlot.registrationDoc:
        return registrationDocUrl;
    }
  }

  void attachPhoto({
    required RegistrationPhotoSlot slot,
    required String url,
  }) {
    switch (slot) {
      case RegistrationPhotoSlot.storeFront:
        storeFrontUrl = url;
      case RegistrationPhotoSlot.interior:
        interiorUrl = url;
      case RegistrationPhotoSlot.registrationDoc:
        registrationDocUrl = url;
    }
  }

  List<String> get uploadedPhotoUrls => [
        if ((storeFrontUrl ?? '').isNotEmpty) storeFrontUrl!,
        if ((interiorUrl ?? '').isNotEmpty) interiorUrl!,
        if ((registrationDocUrl ?? '').isNotEmpty) registrationDocUrl!,
      ];

  /// Shop categories for the dropdown. The widget only shows the field.
  Future<void> loadCategories({VoidCallback? onBusyChanged}) async {
    categoriesLoading = true;
    onBusyChanged?.call();
    try {
      categories = await DiscoveryService.instance.categories();
      if (categories.isNotEmpty &&
          (dropdownValue == null || dropdownValue!.isEmpty)) {
        dropdownValue = categories.first.id;
      }
      final selected = dropdownValue;
      dropdownValueController ??= FormFieldController<String>(selected);
      if (selected != null) {
        dropdownValueController?.value = selected;
      }
    } finally {
      categoriesLoading = false;
      onBusyChanged?.call();
    }
  }

  Future<void> loadCities({VoidCallback? onBusyChanged}) async {
    citiesLoading = true;
    onBusyChanged?.call();
    try {
      cities = await DiscoveryService.instance.cities();
      if (cities.isNotEmpty && (cityValue == null || cityValue!.isEmpty)) {
        cityValue = cities
            .firstWhere((c) => c.name.toLowerCase() == 'degloor',
                orElse: () => cities.first)
            .id;
      }
      final selected = cityValue;
      cityValueController ??= FormFieldController<String>(selected);
      if (selected != null) {
        cityValueController?.value = selected;
      }
    } finally {
      citiesLoading = false;
      onBusyChanged?.call();
    }
  }

  /// Gallery pick plus public upload. The widget only shows the tile.
  Future<void> pickPhoto({
    required String userId,
    required RegistrationPhotoSlot slot,
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
      slot: slot,
      bytes: await image.readAsBytes(),
      onBusyChanged: onBusyChanged,
    );
  }

  Future<void> uploadPhotoBytes({
    required String userId,
    required RegistrationPhotoSlot slot,
    required List<int> bytes,
    VoidCallback? onBusyChanged,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Please login to register a business');
    }
    uploadingSlot = slot;
    onBusyChanged?.call();
    try {
      final url = await BusinessService.instance.uploadPublicImage(
        folder: 'businesses',
        businessId: '$userId/${slot.name}',
        bytes: bytes,
      );
      attachPhoto(slot: slot, url: url);
    } finally {
      uploadingSlot = null;
      onBusyChanged?.call();
    }
  }

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
    textFieldModel8 = createModel(context, () => TextFieldModel());
    textFieldModel9 = createModel(context, () => TextFieldModel());
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
    final address = textFieldModel6.inputTextController?.text ?? '';
    final area = textFieldModel8.inputTextController?.text ?? '';
    final cityName = cities.firstWhere((c) => c.id == cityValue, orElse: () => const City(id: '', name: 'Degloor')).name;

    nameError = name.trim().isEmpty;
    ownerError = owner.trim().isEmpty;
    phoneError = phone.trim().isEmpty;
    addressError = address.trim().isEmpty;
    areaError = area.trim().isEmpty;
    categoryError = dropdownValue == null || dropdownValue!.isEmpty;

    if (nameError ||
        ownerError ||
        phoneError ||
        addressError ||
        areaError ||
        categoryError) {
      if (categoryError && categories.isEmpty) {
        throw Exception('Unable to load categories. Please check your connection.');
      }
      throw Exception('Please fill all required fields');
    }

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
        subcategory: textFieldModel9.inputTextController?.text,
        cityId: cityValue,
        latitude: mapGoogleMapsCenter.latitude,
        longitude: mapGoogleMapsCenter.longitude,
        description: textFieldModel3.inputTextController?.text ?? '',
        whatsappNumber: whatsapp,
        addressText:
            '${textFieldModel6.inputTextController?.text ?? ''}, ${textFieldModel8.inputTextController?.text ?? ''}, $cityName',
        discoveryRadius: radiusFromSliderPercent(sliderVal),
        imageUrl: storeFrontUrl,
        photos: uploadedPhotoUrls.isEmpty ? null : uploadedPhotoUrls,
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
    textFieldModel8.dispose();
    textFieldModel9.dispose();
    buttonModel1.dispose();
    sectionHeaderModel4.dispose();
    sliderModel.dispose();
    sectionHeaderModel5.dispose();
    buttonModel2.dispose();
  }
}
