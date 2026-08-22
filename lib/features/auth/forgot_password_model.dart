import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'forgot_password_widget.dart' show ForgotPasswordWidget;

class ForgotPasswordModel extends FlutterFlowModel<ForgotPasswordWidget> {
  final emailFocusNode = FocusNode();
  final emailController = TextEditingController();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    emailFocusNode.dispose();
    emailController.dispose();
  }
}
