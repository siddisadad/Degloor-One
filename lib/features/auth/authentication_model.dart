import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/discovery_service.dart';
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
  // Model for SocialButton.
  late SocialButtonModel socialButtonModel1;

  String get guestRouteName =>
      isBusinessOwner ? 'BusinessRegistration' : 'CustomerHome';

  Future<String> routeAfterAuth({required bool bypassAuth}) async {
    if (!isBusinessOwner) return '_initialize';
    if (bypassAuth) return 'BusinessRegistration';
    final userId = currentUserUid;
    if (userId.isEmpty) return 'BusinessRegistration';
    try {
      final shops = await DiscoveryService.instance
          .ownedBy(userId)
          .timeout(const Duration(seconds: 10));
      return shops.isEmpty ? 'BusinessRegistration' : 'BusinessDashboard';
    } catch (_) {
      return 'BusinessRegistration';
    }
  }

  @override
  void initState(BuildContext context) {
    textFieldModel1 = createModel(context, () => TextFieldModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    socialButtonModel1 = createModel(context, () => SocialButtonModel());
  }

  @override
  void dispose() {
    textFieldModel1.dispose();
    textFieldModel2.dispose();
    socialButtonModel1.dispose();
  }
}
