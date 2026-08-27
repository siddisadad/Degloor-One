import 'package:degloor_one/auth/password_recovery.dart';
import 'package:degloor_one/components/text_field/text_field_widget.dart';
import 'package:degloor_one/features/auth/auth_continue.dart' as auth_continue;
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'signup_widget.dart' show SignUpWidget;
import 'package:flutter/material.dart';

class SignUpModel extends FlutterFlowModel<SignUpWidget> {
  bool isBusinessOwner = false;

  late TextFieldModel emailModel;
  late TextFieldModel passwordModel;
  late TextFieldModel confirmModel;

  @override
  void initState(BuildContext context) {
    emailModel = createModel(context, () => TextFieldModel());
    passwordModel = createModel(context, () => TextFieldModel());
    confirmModel = createModel(context, () => TextFieldModel());
  }

  String get email => emailModel.inputTextController?.text.trim() ?? '';
  String get password => passwordModel.inputTextController?.text ?? '';
  String get confirm => confirmModel.inputTextController?.text ?? '';

  /// The widget only collects the form. Validation stays here.
  String? validate() {
    if (email.isEmpty || password.isEmpty) {
      return 'Please enter your email and password';
    }
    if (!PasswordRecovery.isValidEmail(email)) {
      return 'Please enter a valid email';
    }
    return PasswordRecovery.validateNewPassword(password, confirm);
  }

  Future<String> routeAfterAuth({required bool bypassAuth}) {
    return auth_continue.routeAfterAuth(
      isBusinessOwner: isBusinessOwner,
      bypassAuth: bypassAuth,
    );
  }

  @override
  void dispose() {
    emailModel.dispose();
    passwordModel.dispose();
    confirmModel.dispose();
  }
}
