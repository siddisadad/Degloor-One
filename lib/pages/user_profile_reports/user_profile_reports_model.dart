import '/backend/supabase/supabase.dart';
import '/components/button/button_widget.dart';
import '/components/profile_option/profile_option_widget.dart';
import '/components/report_item/report_item_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'user_profile_reports_widget.dart' show UserProfileReportsWidget;
import 'package:flutter/material.dart';

class UserProfileReportsModel
    extends FlutterFlowModel<UserProfileReportsWidget> {
  ///  State fields for stateful widgets in this page.

  Future<List<UsersRow>>? userProfileFuture;
  Future<List<OrdersRow>>? ordersFuture;
  Future<List<ComplaintsRow>>? complaintsFuture;

  // Model for ProfileOption.
  late ProfileOptionModel profileOptionModel1;
  // Model for ProfileOption.
  late ProfileOptionModel profileOptionModel2;
  // Model for ProfileOption.
  late ProfileOptionModel profileOptionModel3;
  // Model for ProfileOption.
  late ProfileOptionModel profileOptionModel4;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for ReportItem.
  late ReportItemModel reportItemModel1;
  // Model for ReportItem.
  late ReportItemModel reportItemModel2;
  // Model for ReportItem.
  late ReportItemModel reportItemModel3;
  // Model for ProfileOption.
  late ProfileOptionModel profileOptionModel5;
  // Model for ProfileOption.
  late ProfileOptionModel profileOptionModel6;
  // Model for ProfileOption.
  late ProfileOptionModel profileOptionModel7;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    profileOptionModel1 = createModel(context, () => ProfileOptionModel());
    profileOptionModel2 = createModel(context, () => ProfileOptionModel());
    profileOptionModel3 = createModel(context, () => ProfileOptionModel());
    profileOptionModel4 = createModel(context, () => ProfileOptionModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    reportItemModel1 = createModel(context, () => ReportItemModel());
    reportItemModel2 = createModel(context, () => ReportItemModel());
    reportItemModel3 = createModel(context, () => ReportItemModel());
    profileOptionModel5 = createModel(context, () => ProfileOptionModel());
    profileOptionModel6 = createModel(context, () => ProfileOptionModel());
    profileOptionModel7 = createModel(context, () => ProfileOptionModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    profileOptionModel1.dispose();
    profileOptionModel2.dispose();
    profileOptionModel3.dispose();
    profileOptionModel4.dispose();
    buttonModel1.dispose();
    reportItemModel1.dispose();
    reportItemModel2.dispose();
    reportItemModel3.dispose();
    profileOptionModel5.dispose();
    profileOptionModel6.dispose();
    profileOptionModel7.dispose();
    buttonModel2.dispose();
  }
}
