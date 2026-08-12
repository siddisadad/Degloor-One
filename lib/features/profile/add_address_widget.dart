import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_google_map.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:degloor_one/app_state.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/features/profile/add_address_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
export 'package:degloor_one/features/profile/add_address_model.dart';

class AddAddressWidget extends StatefulWidget {
  const AddAddressWidget({super.key});

  static String routeName = 'AddAddress';
  static String routePath = '/addAddress';

  @override
  State<AddAddressWidget> createState() => _AddAddressWidgetState();
}

class _AddAddressWidgetState extends State<AddAddressWidget> {
  late AddAddressModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddAddressModel());
    _model.mapCenter = FFAppState.instance.userLocation ?? const LatLng(18.5522, 77.5844);
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    if (kIsWeb) {
      return;
    }
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          if (p.name != null && p.name != p.street) p.name,
          p.street,
          p.subLocality,
          p.locality,
          p.postalCode
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _model.addressTextController?.text = address;
        });
      }
    } catch (e) {
      AppLogger.error('Geocoding error', e);
    }
  }

  Future<void> _saveAddress() async {
    if (_model.formKey.currentState!.validate()) {
      if (_model.mapCenter == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location on the map')),
        );
        return;
      }

      await AddressesTable().insert({
        'user_id': currentUserUid,
        'title': _model.titleTextController?.text,
        'address_text': _model.addressTextController?.text,
        'latitude': _model.mapCenter!.latitude,
        'longitude': _model.mapCenter!.longitude,
        'is_default': _model.isDefault,
      });

      if (_model.isDefault) {
        // Unset other defaults if this one is set
        await AddressesTable().update(
          data: {'is_default': false},
          matchingRows: (q) => q.eq('user_id', currentUserUid).neq('is_default', true),
        );
      }

      context.safePop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address saved successfully')),
      );
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          title: Text(
            'Add New Address',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(),
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          child: Form(
            key: _model.formKey,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      FlutterFlowGoogleMap(
                        controller: _model.mapController,
                        onCameraIdle: (latLng) {
                          setState(() => _model.mapCenter = latLng);
                          _reverseGeocode(latLng);
                        },
                        initialLocation: _model.mapCenter,
                        markerColor: GoogleMarkerColor.violet,
                        initialZoom: 15.0,
                        showZoomControls: false,
                        centerMapOnMarkerTap: true,
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 30.0),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _model.titleTextController,
                        focusNode: _model.titleFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Address Title',
                          hintText: 'Home, Office, etc.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) => (val == null || val.isEmpty) ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _model.addressTextController,
                        focusNode: _model.addressFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Address Details',
                          hintText: 'Building, Street, Landmark',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                        validator: (val) => (val == null || val.isEmpty) ? 'Please enter address details' : null,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        value: _model.isDefault,
                        onChanged: (val) => setState(() => _model.isDefault = val),
                        title: const Text('Set as Default Address'),
                        activeThumbColor: FlutterFlowTheme.of(context).primary,
                      ),
                      const SizedBox(height: 24),
                      FFButtonWidget(
                        onPressed: _saveAddress,
                        text: 'Save Address',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
