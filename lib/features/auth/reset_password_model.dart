import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'reset_password_widget.dart' show ResetPasswordWidget;

class ResetPasswordModel extends FlutterFlowModel<ResetPasswordWidget> {
  final passwordFocusNode = FocusNode();
  final confirmFocusNode = FocusNode();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    passwordFocusNode.dispose();
    confirmFocusNode.dispose();
    passwordController.dispose();
    confirmController.dispose();
  }
}
