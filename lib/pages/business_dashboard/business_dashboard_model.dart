import '/components/action_tile/action_tile_widget.dart';
import '/components/completeness_card/completeness_card_widget.dart';
import '/components/stat_card/stat_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'business_dashboard_widget.dart' show BusinessDashboardWidget;
import 'package:flutter/material.dart';

class BusinessDashboardModel extends FlutterFlowModel<BusinessDashboardWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for StatCard.
  late StatCardModel statCardModel1;
  // Model for StatCard.
  late StatCardModel statCardModel2;
  // Model for StatCard.
  late StatCardModel statCardModel3;
  // Model for StatCard.
  late StatCardModel statCardModel4;
  // Model for CompletenessCard.
  late CompletenessCardModel completenessCardModel;
  // Model for ActionTile.
  late ActionTileModel actionTileModel1;
  // Model for ActionTile.
  late ActionTileModel actionTileModel2;
  // Model for ActionTile.
  late ActionTileModel actionTileModel3;
  // Model for ActionTile.
  late ActionTileModel actionTileModel4;
  // Model for ActionTile.
  late ActionTileModel actionTileModel5;

  @override
  void initState(BuildContext context) {
    statCardModel1 = createModel(context, () => StatCardModel());
    statCardModel2 = createModel(context, () => StatCardModel());
    statCardModel3 = createModel(context, () => StatCardModel());
    statCardModel4 = createModel(context, () => StatCardModel());
    completenessCardModel = createModel(context, () => CompletenessCardModel());
    actionTileModel1 = createModel(context, () => ActionTileModel());
    actionTileModel2 = createModel(context, () => ActionTileModel());
    actionTileModel3 = createModel(context, () => ActionTileModel());
    actionTileModel4 = createModel(context, () => ActionTileModel());
    actionTileModel5 = createModel(context, () => ActionTileModel());
  }

  @override
  void dispose() {
    statCardModel1.dispose();
    statCardModel2.dispose();
    statCardModel3.dispose();
    statCardModel4.dispose();
    completenessCardModel.dispose();
    actionTileModel1.dispose();
    actionTileModel2.dispose();
    actionTileModel3.dispose();
    actionTileModel4.dispose();
    actionTileModel5.dispose();
  }
}
