import 'package:degloor_one/components/completeness_card/completeness_card_widget.dart';
import 'package:degloor_one/components/stat_card/stat_card_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'business_dashboard_widget.dart' show BusinessDashboardWidget;
import 'package:flutter/material.dart';

class BusinessDashboardModel extends FlutterFlowModel<BusinessDashboardWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for StatCard.
  late StatCardModel statCardModel1;
  late StatCardModel statCardModel2;
  late StatCardModel statCardModel3;
  late StatCardModel statCardModel4;

  // Model for CompletenessCard.
  late CompletenessCardModel completenessCardModel;

  @override
  void initState(BuildContext context) {
    statCardModel1 = createModel(context, () => StatCardModel());
    statCardModel2 = createModel(context, () => StatCardModel());
    statCardModel3 = createModel(context, () => StatCardModel());
    statCardModel4 = createModel(context, () => StatCardModel());
    completenessCardModel = createModel(context, () => CompletenessCardModel());
  }

  @override
  void dispose() {
    statCardModel1.dispose();
    statCardModel2.dispose();
    statCardModel3.dispose();
    statCardModel4.dispose();
    completenessCardModel.dispose();
  }
}
