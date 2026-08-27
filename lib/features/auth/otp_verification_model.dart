import '/flutter_flow/flutter_flow_util.dart';
import 'otp_verification_widget.dart' show OtpVerificationWidget;
import 'package:flutter/material.dart';

class OtpVerificationModel extends FlutterFlowModel<OtpVerificationWidget> {
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
