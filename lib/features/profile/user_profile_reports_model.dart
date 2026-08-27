import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'user_profile_reports_widget.dart' show UserProfileReportsWidget;
import 'package:flutter/material.dart';

class UserProfileReportsModel
    extends FlutterFlowModel<UserProfileReportsWidget> {
  ///  State fields for stateful widgets in this page.

  Future<List<UserProfile>>? userProfileFuture;
  Future<List<ListingComplaint>>? complaintsFuture;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
