import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'user_profile_reports_widget.dart' show UserProfileReportsWidget;
import 'package:flutter/material.dart';

class UserProfileReportsModel
    extends FlutterFlowModel<UserProfileReportsWidget> {
  ///  State fields for stateful widgets in this page.

  Future<List<UserProfile>>? userProfileFuture;
  Future<List<ComplaintsRow>>? complaintsFuture;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
