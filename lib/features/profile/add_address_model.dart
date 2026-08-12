import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart' show GoogleMapController;
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/features/profile/add_address_widget.dart' show AddAddressWidget;
import 'package:flutter/material.dart';

class AddAddressModel extends FlutterFlowModel<AddAddressWidget> {
  ///  State fields for stateful widgets in this page.
  final formKey = GlobalKey<FormState>();

  // State field(s) for Map widget.
  LatLng? mapCenter;
  final mapController = Completer<GoogleMapController>();

  // State field(s) for TextField widget.
  FocusNode? titleFocusNode;
  TextEditingController? titleTextController;
  String? Function(BuildContext, String?)? titleTextControllerValidator;

  // State field(s) for TextField widget.
  FocusNode? addressFocusNode;
  TextEditingController? addressTextController;
  String? Function(BuildContext, String?)? addressTextControllerValidator;

  bool isDefault = false;

  @override
  void initState(BuildContext context) {
    titleTextController ??= TextEditingController();
    addressTextController ??= TextEditingController();
  }

  @override
  void dispose() {
    titleFocusNode?.dispose();
    titleTextController?.dispose();
    addressFocusNode?.dispose();
    addressTextController?.dispose();
  }
}
