import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class ApplyJobSheetModel extends FlutterFlowModel {
  // State field(s) for experience widget.
  FocusNode? experienceFocusNode;
  TextEditingController? experienceController;
  String? Function(BuildContext, String?)? experienceControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    experienceFocusNode?.dispose();
    experienceController?.dispose();
  }
}
