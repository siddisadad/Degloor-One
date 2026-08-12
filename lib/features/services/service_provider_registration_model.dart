import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/features/services/service_provider_registration_widget.dart' show ServiceProviderRegistrationWidget;
import 'package:flutter/material.dart';

class ServiceProviderRegistrationModel extends FlutterFlowModel<ServiceProviderRegistrationWidget> {
  final formKey = GlobalKey<FormState>();

  // State field(s) for Dropdown.
  String? categoryValue;

  // State field(s) for Experience TextField.
  FocusNode? experienceFocusNode;
  TextEditingController? experienceTextController;

  // State field(s) for HourlyRate TextField.
  FocusNode? rateFocusNode;
  TextEditingController? rateTextController;

  // State field(s) for Bio TextField.
  FocusNode? bioFocusNode;
  TextEditingController? bioTextController;

  @override
  void initState(BuildContext context) {
    experienceTextController ??= TextEditingController();
    rateTextController ??= TextEditingController();
    bioTextController ??= TextEditingController();
  }

  @override
  void dispose() {
    experienceFocusNode?.dispose();
    experienceTextController?.dispose();
    rateFocusNode?.dispose();
    rateTextController?.dispose();
    bioFocusNode?.dispose();
    bioTextController?.dispose();
  }
}
