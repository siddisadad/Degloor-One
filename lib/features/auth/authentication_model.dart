import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/social_button/social_button_widget.dart';
import 'package:degloor_one/components/text_field/text_field_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'authentication_widget.dart' show AuthenticationWidget;
import 'package:flutter/material.dart';

class AuthenticationModel extends FlutterFlowModel<AuthenticationWidget> {
  ///  State fields for stateful widgets in this page.

  bool isBusinessOwner = false;
  // Model for TextField.
  late TextFieldModel textFieldModel1;
  // Model for TextField.
  late TextFieldModel textFieldModel2;
  // Model for Button.
  late ButtonModel buttonModel;
  // Model for SocialButton.
  late SocialButtonModel socialButtonModel1;
  // Model for SocialButton.
  late SocialButtonModel socialButtonModel2;

  @override
  void initState(BuildContext context) {
    textFieldModel1 = createModel(context, () => TextFieldModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    buttonModel = createModel(context, () => ButtonModel());
    socialButtonModel1 = createModel(context, () => SocialButtonModel());
    socialButtonModel2 = createModel(context, () => SocialButtonModel());
  }

  @override
  void dispose() {
    textFieldModel1.dispose();
    textFieldModel2.dispose();
    buttonModel.dispose();
    socialButtonModel1.dispose();
    socialButtonModel2.dispose();
  }
}
