import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/backend/location_service.dart';
import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
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
      await _model.loadCategories(
        onBusyChanged: () {
          if (mounted) setState(() {});
        },
      );
    } catch (e) {
      AppLogger.error('Error loading categories', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLogger.userFacingMessage(
              e,
              fallback: 'Unable to load categories. Please try again.',
            ),
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _pickPhoto(RegistrationPhotoSlot slot) async {
    try {
      await _model.pickPhoto(
        userId: currentUserUid,
        slot: slot,
        onBusyChanged: () {
          if (mounted) setState(() {});
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLogger.userFacingMessage(
              e,
              fallback: 'Unable to upload the photo. Please try again.',
            ),
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Widget _photoSlot({
    required RegistrationPhotoSlot slot,
    required String label,
    required IconData icon,
  }) {
    final url = _model.photoUrl(slot);
    final uploading = _model.uploadingSlot == slot;
    final labelStyle = FlutterFlowTheme.of(context).labelSmall.override(
          font: GoogleFonts.inter(
            fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
          ),
          color: FlutterFlowTheme.of(context).secondaryText,
          letterSpacing: 0.0,
          fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
          fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
          lineHeight: 1.2,
        );
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: _isSubmitting ? null : () => _pickPhoto(slot),
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          key: ValueKey('registration-photo-${slot.name}'),
          width: 110.0,
          height: 110.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate,
            ),
          ),
          alignment: const AlignmentDirectional(0.0, 0.0),
          clipBehavior: Clip.antiAlias,
          child: uploading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (url != null && url.isNotEmpty)
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedRemoteImage(
                          url: url,
                          width: 110,
                          height: 110,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: labelStyle.override(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 24.0,
                        ),
                        Text(label, style: labelStyle),
                      ].divide(const SizedBox(height: 4.0)),
                    ),
        ),
      ),
    );
  }

  Future<void> _submitRegistration() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final route = await _model.submit(userId: currentUserUid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Business submitted for verification!'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
      context.goNamed(route);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLogger.userFacingMessage(
              e,
              fallback: 'Unable to submit the shop. Please try again.',
            ),
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          onPressed: () {
                            context.popOrGoNamed(CustomerHomeWidget.routeName);
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
                        if (_model.categoriesLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(),
                          )
                        else if (_model.categories.isEmpty)
                          TextButton(
                            onPressed: _isSubmitting ? null : _loadCategories,
                            child: Text(
                              'Unable to load categories. Tap to retry.',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context).error,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          )
                        else
                          FlutterFlowDropDown<String>(
                            key: ValueKey(
                              'registration-category-${_model.categories.length}',
                            ),
                            controller: _model.dropdownValueController ??=
                                FormFieldController<String>(
                              _model.dropdownValue,
                            ),
                            options:
                                _model.categories.map((c) => c.id).toList(),
                            optionLabels:
                                _model.categories.map((c) => c.name).toList(),
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
                                    initialLocation: _model.mapGoogleMapsCenter,
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                          children: [
                            _photoSlot(
                              slot: RegistrationPhotoSlot.storeFront,
                              label: 'Store Front',
                              icon: Icons.add_a_photo_rounded,
                            ),
                            _photoSlot(
                              slot: RegistrationPhotoSlot.interior,
                              label: 'Interior',
                              icon: Icons.add_photo_alternate_rounded,
                            ),
                            _photoSlot(
                              slot: RegistrationPhotoSlot.registrationDoc,
                              label: 'Reg. Doc',
                              icon: Icons.description_rounded,
                            ),
                          ].divide(const SizedBox(width: 16.0)),
                        ),
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
                          wrapWithModel(
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
                              onTap: _isSubmitting ? null : _submitRegistration,
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
    );
  }
}
