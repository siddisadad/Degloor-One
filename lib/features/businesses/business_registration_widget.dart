import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/backend/location_service.dart';
import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/section_header/section_header_widget.dart';
import 'package:degloor_one/components/slider/slider_widget.dart';
import 'package:degloor_one/components/switch_component/switch_component_widget.dart';
import 'package:degloor_one/components/text_field/text_field_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_drop_down.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_google_map.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/form_field_controller.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/supabase/database/database.dart';
import 'package:degloor_one/features/home/customer_home_widget.dart';
import 'package:degloor_one/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/core/google_maps_js.dart';
import 'package:degloor_one/shared/discovery_radius.dart';
import 'business_registration_model.dart';
export 'business_registration_model.dart';

class BusinessRegistrationWidget extends StatefulWidget {
  const BusinessRegistrationWidget({super.key});

  static String routeName = 'BusinessRegistration';
  static String routePath = '/businessRegistration';

  @override
  State<BusinessRegistrationWidget> createState() =>
      _BusinessRegistrationWidgetState();
}

class _BusinessRegistrationWidgetState
    extends State<BusinessRegistrationWidget> {
  late BusinessRegistrationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<BusinessCategoriesRow> _categories = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessRegistrationModel());
    _loadCategories();
    _model.sliderModel.sliderValue =
        sliderPercentFromRadius(kDefaultDiscoveryRadiusKm);
  }

  Future<void> _loadCategories() async {
    try {
      final rows = await DiscoveryService.instance.categories();
      if (mounted) {
        setState(() {
          _categories = rows;
          if (_categories.isNotEmpty) {
            _model.dropdownValue = _categories.first.id;
          }
        });
      }
    } catch (e) {
      AppLogger.error('Error loading categories', e);
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        FlutterFlowIconButton(
                          borderRadius: 8.0,
                          buttonSize: 40.0,
                          fillColor: Colors.transparent,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            context.goNamed(CustomerHomeWidget.routeName);
                          },
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register Business',
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                            Text(
                              'Phase 1: DEGLOOR ONE',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                    lineHeight: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ].divide(const SizedBox(width: 16.0)),
                    ),
                    wrapWithModel(
                      model: _model.sectionHeaderModel1,
                      updateCallback: () => safeSetState(() {}),
                      child: const SectionHeaderWidget(
                        step: '1',
                        title: 'Business Identity',
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        wrapWithModel(
                          model: _model.textFieldModel1,
                          updateCallback: () => safeSetState(() {}),
                          child: TextFieldWidget(
                            label: 'Business Name',
                            labelPresent: true,
                            helper: '',
                            helperPresent: false,
                            leadingIcon: Icon(
                              Icons.business_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            leadingIconPresent: true,
                            trailingIconPresent: false,
                            hint: 'e.g., Maharashtra Hardware & Steel',
                            value: '',
                            onSubmit: (_) {},
                            variant: 'outlined',
                            error: false,
                          ),
                        ),
                        wrapWithModel(
                          model: _model.textFieldModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: TextFieldWidget(
                            label: 'Owner Name',
                            labelPresent: true,
                            helper: '',
                            helperPresent: false,
                            leadingIcon: Icon(
                              Icons.person_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            leadingIconPresent: true,
                            trailingIconPresent: false,
                            hint: 'Full legal name of proprietor',
                            value: '',
                            onSubmit: (_) {},
                            variant: 'outlined',
                            error: false,
                          ),
                        ),
                        if (_categories.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(),
                          )
                        else
                          FlutterFlowDropDown<String>(
                            controller: _model.dropdownValueController ??=
                                FormFieldController<String>(
                              _model.dropdownValue,
                            ),
                            options: _categories.map((c) => c.id).toList(),
                            optionLabels:
                                _categories.map((c) => c.name).toList(),
                            onChanged: (val) => safeSetState(
                                () => _model.dropdownValue = val),
                            width: double.infinity,
                            height: 48.0,
                            textStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(),
                                  letterSpacing: 0.0,
                                  lineHeight: 1.5,
                                ),
                            hintText: 'Select Category',
                            icon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 24.0,
                            ),
                            fillColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            elevation: 2.0,
                            borderColor: FlutterFlowTheme.of(context).alternate,
                            borderWidth: 1.0,
                            borderRadius: 8.0,
                            margin: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            hidesUnderline: true,
                            labelText: 'Primary Category',
                            labelTextStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.inter(),
                                  letterSpacing: 0.0,
                                  lineHeight: 1.4,
                                ),
                          ),
                        wrapWithModel(
                          model: _model.textFieldModel3,
                          updateCallback: () => safeSetState(() {}),
                          child: TextFieldWidget(
                            label: 'Business Description',
                            labelPresent: true,
                            helper: '',
                            helperPresent: false,
                            leadingIconPresent: false,
                            trailingIconPresent: false,
                            hint:
                                'Briefly describe your products or services...',
                            value: '',
                            onSubmit: (_) {},
                            variant: 'outlined',
                            error: false,
                          ),
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                    wrapWithModel(
                      model: _model.sectionHeaderModel2,
                      updateCallback: () => safeSetState(() {}),
                      child: const SectionHeaderWidget(
                        step: '2',
                        title: 'Contact Details',
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        wrapWithModel(
                          model: _model.textFieldModel4,
                          updateCallback: () => safeSetState(() {}),
                          child: TextFieldWidget(
                            label: 'Mobile Number',
                            labelPresent: true,
                            helper: '',
                            helperPresent: false,
                            leadingIcon: Icon(
                              Icons.phone_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            leadingIconPresent: true,
                            trailingIconPresent: false,
                            hint: '+91 98765 43210',
                            value: '',
                            onSubmit: (_) {},
                            variant: 'outlined',
                            error: false,
                          ),
                        ),
                        wrapWithModel(
                          model: _model.textFieldModel5,
                          updateCallback: () => safeSetState(() {}),
                          child: TextFieldWidget(
                            label: 'WhatsApp Number',
                            labelPresent: true,
                            helper: '',
                            helperPresent: false,
                            leadingIcon: Icon(
                              Icons.chat_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            leadingIconPresent: true,
                            trailingIconPresent: false,
                            hint: 'For customer enquiries',
                            value: '',
                            onSubmit: (_) {},
                            variant: 'outlined',
                            error: false,
                          ),
                        ),
                        wrapWithModel(
                          model: _model.switchModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const SwitchComponentWidget(
                            label: 'WhatsApp same as mobile',
                            labelPresent: true,
                            variant: 'Android',
                            active: true,
                          ),
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                    wrapWithModel(
                      model: _model.sectionHeaderModel3,
                      updateCallback: () => safeSetState(() {}),
                      child: const SectionHeaderWidget(
                        step: '3',
                        title: 'Location & GPS',
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        wrapWithModel(
                          model: _model.textFieldModel6,
                          updateCallback: () => safeSetState(() {}),
                          child: TextFieldWidget(
                            label: 'Street Address',
                            labelPresent: true,
                            helper: '',
                            helperPresent: false,
                            leadingIcon: Icon(
                              Icons.store_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            leadingIconPresent: true,
                            trailingIconPresent: false,
                            hint: 'Shop No., Building Name, Main Road...',
                            value: '',
                            onSubmit: (_) {},
                            variant: 'outlined',
                            error: false,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 180.0,
                              child: wrapWithModel(
                                model: _model.textFieldModel7,
                                updateCallback: () => safeSetState(() {}),
                                child: TextFieldWidget(
                                  label: 'City',
                                  labelPresent: true,
                                  helper: '',
                                  helperPresent: false,
                                  leadingIconPresent: false,
                                  trailingIconPresent: false,
                                  hint: 'Type here...',
                                  value: 'Degloor',
                                  onSubmit: (_) {},
                                  variant: 'outlined',
                                  error: false,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 180.0,
                              child: wrapWithModel(
                                model: _model.textFieldModel8,
                                updateCallback: () => safeSetState(() {}),
                                child: TextFieldWidget(
                                  label: 'Area',
                                  labelPresent: true,
                                  helper: '',
                                  helperPresent: false,
                                  leadingIconPresent: false,
                                  trailingIconPresent: false,
                                  hint: 'e.g., Shivaji Chowk',
                                  value: '',
                                  onSubmit: (_) {},
                                  variant: 'outlined',
                                  error: false,
                                ),
                              ),
                            ),
                          ].divide(const SizedBox(width: 16.0)),
                        ),
                        Text(
                          'Set GPS Coordinates',
                          style: FlutterFlowTheme.of(context)
                              .labelLarge
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .labelLarge
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelLarge
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            height: 200.0,
                            decoration: BoxDecoration(
                              color:
                                  FlutterFlowTheme.of(context).surfaceVariant,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: 300.0,
                                  height: 200.0,
                                  child: FlutterFlowGoogleMap(
                                    controller: _model.mapGoogleMapsController,
                                    onCameraIdle: (latLng) =>
                                        _model.mapGoogleMapsCenter = latLng,
                                    initialLocation:
                                        _model.mapGoogleMapsCenter ??=
                                            const LatLng(18.5522, 77.5844),
                                    markerColor: GoogleMarkerColor.violet,
                                    initialZoom: 15.0,
                                    showZoomControls: false,
                                    showLocation: false,
                                    centerMapOnMarkerTap: true,
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: FlutterFlowTheme.of(context).error,
                                      size: 36.0,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(1.0, 1.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: wrapWithModel(
                                      model: _model.buttonModel1,
                                      updateCallback: () => safeSetState(() {}),
                                      child: ButtonWidget(
                                        icon: Icon(
                                          Icons.my_location,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                        iconPresent: true,
                                        iconEndPresent: false,
                                        content: 'Locate Me',
                                        variant: 'secondary',
                                        size: 'small',
                                        fullWidth: false,
                                        loading: false,
                                        disabled: false,
                                        onTap: () async {
                                          await LocationService
                                              .updateCurrentLocation(context);
                                          if (!context.mounted) return;
                                          final userLoc =
                                              FFAppState.instance.userLocation;
                                          if (userLoc != null) {
                                            _model.mapGoogleMapsCenter =
                                                userLoc;
                                            if (isGoogleMapsJsReady()) {
                                              final controller = await _model
                                                  .mapGoogleMapsController
                                                  .future;
                                              await controller.animateCamera(
                                                CameraUpdate.newLatLng(
                                                  userLoc.toGoogleMaps(),
                                                ),
                                              );
                                            }
                                            safeSetState(() {});
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                    wrapWithModel(
                      model: _model.sectionHeaderModel4,
                      updateCallback: () => safeSetState(() {}),
                      child: const SectionHeaderWidget(
                        step: '4',
                        title: 'Discovery Reach',
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Service Radius',
                          style: FlutterFlowTheme.of(context)
                              .labelLarge
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .labelLarge
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelLarge
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                        ),
                        Text(
                          'How far should customers be able to discover your business?',
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .fontStyle,
                                lineHeight: 1.5,
                              ),
                        ),
                        wrapWithModel(
                          model: _model.sliderModel,
                          updateCallback: () => safeSetState(() {}),
                          child: SliderWidget(
                            label: 'Discovery Radius (KM)',
                            labelPresent: true,
                            description: '',
                            descriptionPresent: false,
                            valueLabel:
                                '${radiusFromSliderPercent(_model.sliderModel.sliderValue ?? sliderPercentFromRadius(kDefaultDiscoveryRadiusKm)).toInt()} KM',
                            valueLabelPresent: true,
                            step: 0.0,
                            divisions: 2,
                            valuePercentage: _model.sliderModel.sliderValue ??
                                sliderPercentFromRadius(
                                    kDefaultDiscoveryRadiusKm),
                            color: FlutterFlowTheme.of(context).primary,
                            variant: 'Material',
                            disabled: false,
                            showTicks: true,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '5 KM',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                    lineHeight: 1.2,
                                  ),
                            ),
                            Text(
                              '15 KM',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                    lineHeight: 1.2,
                                  ),
                            ),
                          ],
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                    wrapWithModel(
                      model: _model.sectionHeaderModel5,
                      updateCallback: () => safeSetState(() {}),
                      child: const SectionHeaderWidget(
                        step: '5',
                        title: 'Photos & Verification',
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Upload clear photos of your storefront and interior.',
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .fontStyle,
                                lineHeight: 1.5,
                              ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 110.0,
                              height: 110.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                              ),
                              alignment: const AlignmentDirectional(0.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                  Text(
                                    'Store Front',
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                          lineHeight: 1.2,
                                        ),
                                  ),
                                ].divide(const SizedBox(height: 4.0)),
                              ),
                            ),
                            Container(
                              width: 110.0,
                              height: 110.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                              ),
                              alignment: const AlignmentDirectional(0.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                  Text(
                                    'Interior',
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                          lineHeight: 1.2,
                                        ),
                                  ),
                                ].divide(const SizedBox(height: 4.0)),
                              ),
                            ),
                            Container(
                              width: 110.0,
                              height: 110.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                              ),
                              alignment: const AlignmentDirectional(0.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.description_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                  Text(
                                    'Reg. Doc',
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                          lineHeight: 1.2,
                                        ),
                                  ),
                                ].divide(const SizedBox(height: 4.0)),
                              ),
                            ),
                          ].divide(const SizedBox(width: 16.0)),
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          24.0, 0.0, 24.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              if (currentUserUid == '') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Please login to register a business'),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).error,
                                  ),
                                );
                                return;
                              }

                              final name = _model.textFieldModel1
                                  .inputTextController?.text
                                  .trim();
                              final owner = _model.textFieldModel2
                                  .inputTextController?.text
                                  .trim();
                              final phone = _model.textFieldModel4
                                  .inputTextController?.text
                                  .trim();

                              if (name == null ||
                                  name.isEmpty ||
                                  owner == null ||
                                  owner.isEmpty ||
                                  phone == null ||
                                  phone.isEmpty ||
                                  _model.dropdownValue == null ||
                                  _model.mapGoogleMapsCenter == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Please fill all required fields (Name, Owner, Phone, Category, and Location)'),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).error,
                                  ),
                                );
                                return;
                              }

                              setState(() => _isSubmitting = true);

                              try {
                                final sliderVal =
                                    _model.sliderModel.sliderValue ??
                                        sliderPercentFromRadius(
                                            kDefaultDiscoveryRadiusKm);
                                final radiusKm =
                                    radiusFromSliderPercent(sliderVal);

                                await BusinessService.instance.register(
                                  userId: currentUserUid,
                                  name: name,
                                  ownerName: owner,
                                  phone: phone,
                                  categoryId: _model.dropdownValue!,
                                  latitude:
                                      _model.mapGoogleMapsCenter!.latitude,
                                  longitude:
                                      _model.mapGoogleMapsCenter!.longitude,
                                  description: _model.textFieldModel3
                                          .inputTextController?.text ??
                                      '',
                                  whatsappNumber:
                                      _model.switchModel.switchValue == true
                                          ? phone
                                          : _model.textFieldModel5
                                              .inputTextController?.text,
                                  addressText:
                                      '${_model.textFieldModel6.inputTextController?.text ?? ''}, ${_model.textFieldModel8.inputTextController?.text ?? ''}, ${_model.textFieldModel7.inputTextController?.text ?? 'Degloor'}',
                                  discoveryRadius: radiusKm,
                                );

                                // Refresh user to update local role
                                await authManager.refreshUser();

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Business submitted for verification!'),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).success,
                                  ),
                                );

                                context.goNamed('BusinessDashboard');
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLogger.userFacingMessage(
                                        e,
                                        fallback:
                                            'Unable to submit the shop. Please try again.',
                                      ),
                                    ),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).error,
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isSubmitting = false);
                                }
                              }
                            },
                            child: wrapWithModel(
                              model: _model.buttonModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: ButtonWidget(
                                iconPresent: false,
                                iconEndPresent: false,
                                content: 'Submit for Verification',
                                variant: 'primary',
                                size: 'large',
                                fullWidth: true,
                                loading: _isSubmitting,
                                disabled: _isSubmitting,
                              ),
                            ),
                          ),
                          Text(
                            'By submitting, you agree to the DEGLOOR ONE Business Terms. Your listing will be reviewed by our local admin team for verification within 24 hours.',
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: FlutterFlowTheme.of(context)
                                .labelSmall
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontStyle,
                                  lineHeight: 1.2,
                                ),
                          ),
                        ].divide(const SizedBox(height: 16.0)),
                      ),
                    ),
                    Container(
                      height: 24.0,
                    ),
                  ].divide(const SizedBox(height: 24.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
