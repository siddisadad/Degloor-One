import '/flutter_flow/flutter_flow_util.dart';
import 'phone_auth_widget.dart' show PhoneAuthWidget;
import 'package:flutter/material.dart';

class PhoneAuthModel extends FlutterFlowModel<PhoneAuthWidget> {
  final textFieldFocusNode = FocusNode();
  final textController = TextEditingController();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode.dispose();
    textController.dispose();
  }
}
