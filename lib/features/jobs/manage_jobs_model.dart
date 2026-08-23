import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class ManageJobsModel extends FlutterFlowModel {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  // Business ID for the owner.
  String? businessId;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
