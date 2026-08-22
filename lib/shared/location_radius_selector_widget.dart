import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/location_item/location_item_widget.dart';
import 'package:degloor_one/components/radius_option/radius_option_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_google_map.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/backend/location_service.dart';
import 'package:degloor_one/core/google_maps_js.dart';
import 'location_radius_selector_model.dart';
export 'location_radius_selector_model.dart';

class LocationRadiusSelectorWidget extends StatefulWidget {
  const LocationRadiusSelectorWidget({super.key});

  static String routeName = 'LocationRadiusSelector';
  static String routePath = '/locationRadiusSelector';

  @override
  State<LocationRadiusSelectorWidget> createState() =>
      _LocationRadiusSelectorWidgetState();
}

class _LocationRadiusSelectorWidgetState
    extends State<LocationRadiusSelectorWidget> {
  late LocationRadiusSelectorModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late double _selectedRadius;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LocationRadiusSelectorModel());
    _selectedRadius = FFAppState.instance.discoveryRadius;
    _model.mapGoogleMapsCenter = FFAppState.instance.userLocation;
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
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 40.0,
                        fillColor: Colors.transparent,
                        icon: Icon(
                          Icons.close_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          context.safePop();
                        },
                      ),
                      Text(
                        'Set Discovery Area',
                        style: FlutterFlowTheme.of(context)
                            .titleMedium
                            .override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .fontStyle,
                              lineHeight: 1.4,
                            ),
                      ),
                      InkWell(
                        onTap: () async {
                          FFAppState.instance.discoveryRadius = _selectedRadius;
                          if (_model.mapGoogleMapsCenter != null) {
                            FFAppState.instance.userLocation = _model.mapGoogleMapsCenter;
                          }
                          context.safePop();
                        },
                        child: wrapWithModel(
                          model: _model.buttonModel1,
                          updateCallback: () => safeSetState(() {}),
                          child: const ButtonWidget(
                            iconPresent: false,
                            iconEndPresent: false,
                            content: 'Done',
                            variant: 'ghost',
                            size: 'small',
                            fullWidth: false,
                            loading: false,
                            disabled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 300.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 300.0,
                      child: FlutterFlowGoogleMap(
                        controller: _model.mapGoogleMapsController,
                        onCameraIdle: (latLng) =>
                            _model.mapGoogleMapsCenter = latLng,
                        initialLocation: _model.mapGoogleMapsCenter ??=
                            const LatLng(18.5522, 77.5844),
                        markerColor: GoogleMarkerColor.violet,
                        showZoomControls: false,
                        showLocation: false,
                        centerMapOnMarkerTap: true,
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 40.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primaryText,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12.0, 6.0, 12.0, 6.0),
                                child: Text(
                                  'Degloor, Maharashtra',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                        ),
                                        color:
                                            FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .fontStyle,
                                        lineHeight: 1.2,
                                      ),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: FlutterFlowTheme.of(context)
                                  .primaryText,
                              size: 32.0,
                            ),
                          ].divide(const SizedBox(height: 0.0)),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(-1.0, -1.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: InkWell(
                          onTap: () async {
                            await LocationService.updateCurrentLocation(context);
                            if (!mounted) return;
                            setState(() {
                              _model.mapGoogleMapsCenter = FFAppState.instance.userLocation;
                            });
                            if (_model.mapGoogleMapsCenter != null &&
                                isGoogleMapsJsReady()) {
                              final controller = await _model.mapGoogleMapsController.future;
                              controller.animateCamera(CameraUpdate.newLatLng(
                                google_maps.LatLng(
                                  _model.mapGoogleMapsCenter!.latitude,
                                  _model.mapGoogleMapsCenter!.longitude,
                                ),
                              ));
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.my_location_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discovery Radius',
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondary13,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    10.0, 4.0, 10.0, 4.0),
                                child: Text(
                                  'Default: 10 KM',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .onSurface,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .fontStyle,
                                        lineHeight: 1.2,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.radiusOptionModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: RadiusOptionWidget(
                                      value: '2',
                                      selected: _selectedRadius == 2,
                                      onTap: () => setState(() => _selectedRadius = 2),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.radiusOptionModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: RadiusOptionWidget(
                                      value: '5',
                                      selected: _selectedRadius == 5,
                                      onTap: () => setState(() => _selectedRadius = 5),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.radiusOptionModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: RadiusOptionWidget(
                                      value: '10',
                                      selected: _selectedRadius == 10,
                                      onTap: () => setState(() => _selectedRadius = 10),
                                    ),
                                  ),
                                ),
                              ].divide(const SizedBox(width: 16.0)),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.radiusOptionModel4,
                                    updateCallback: () => safeSetState(() {}),
                                    child: RadiusOptionWidget(
                                      value: '15',
                                      selected: _selectedRadius == 15,
                                      onTap: () => setState(() => _selectedRadius = 15),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.radiusOptionModel5,
                                    updateCallback: () => safeSetState(() {}),
                                    child: RadiusOptionWidget(
                                      value: '25',
                                      selected: _selectedRadius == 25,
                                      onTap: () => setState(() => _selectedRadius = 25),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(),
                                ),
                              ].divide(const SizedBox(width: 16.0)),
                            ),
                          ].divide(const SizedBox(height: 8.0)),
                        ),
                        Text(
                          'Businesses within this range will be shown in your search results.',
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
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                    Divider(
                      height: 16.0,
                      thickness: 1.0,
                      indent: 0.0,
                      endIndent: 0.0,
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Locations',
                          style: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                wrapWithModel(
                                  model: _model.locationItemModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: LocationItemWidget(
                                    icon: Icon(
                                      Icons.home_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 20.0,
                                    ),
                                    subtitle: 'Station Road, Degloor, 445102',
                                    title: 'Home',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.locationItemModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: LocationItemWidget(
                                    icon: Icon(
                                      Icons.work_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 20.0,
                                    ),
                                    subtitle: 'Industrial Area, Degloor',
                                    title: 'Work',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.locationItemModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: LocationItemWidget(
                                    icon: Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 20.0,
                                    ),
                                    subtitle: 'Search for a specific address',
                                    title: 'Add Custom Location',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                    InkWell(
                      onTap: () async {
                        await LocationService.updateCurrentLocation(context);
                        if (!mounted) return;
                        setState(() {
                          _model.mapGoogleMapsCenter = FFAppState.instance.userLocation;
                        });
                        if (_model.mapGoogleMapsCenter != null &&
                            isGoogleMapsJsReady()) {
                          final controller = await _model.mapGoogleMapsController.future;
                          controller.animateCamera(CameraUpdate.newLatLng(
                            google_maps.LatLng(
                              _model.mapGoogleMapsCenter!.latitude,
                              _model.mapGoogleMapsCenter!.longitude,
                            ),
                          ));
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            children: [
                              Container(
                                width: 48.0,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).success13,
                                  borderRadius: BorderRadius.circular(9999.0),
                                ),
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.location_searching_rounded,
                                  color: FlutterFlowTheme.of(context).onSuccess,
                                  size: 24.0,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Use Current Location',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.5,
                                          ),
                                    ),
                                    Text(
                                      'Pinpoint your exact GPS coordinates',
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
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: FlutterFlowTheme.of(context).onSurface,
                                size: 16.0,
                              ),
                            ].divide(const SizedBox(width: 16.0)),
                          ),
                        ),
                      ),
                    ),
                  ].divide(const SizedBox(height: 24.0)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 1.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: InkWell(
                        onTap: () async {
                          FFAppState.instance.discoveryRadius = _selectedRadius;
                          if (_model.mapGoogleMapsCenter != null) {
                            FFAppState.instance.userLocation = _model.mapGoogleMapsCenter;
                          }
                          context.safePop();
                        },
                        child: wrapWithModel(
                          model: _model.buttonModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: const ButtonWidget(
                            iconPresent: false,
                            iconEndPresent: false,
                            content: 'Apply Location & Radius',
                            variant: 'primary',
                            size: 'large',
                            fullWidth: true,
                            loading: false,
                            disabled: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
