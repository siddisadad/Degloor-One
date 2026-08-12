import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/stat_card2/stat_card2_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'admin_control_panel_widget.dart' show AdminControlPanelWidget;
import 'package:flutter/material.dart';

class AdminControlPanelModel extends FlutterFlowModel<AdminControlPanelWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for StatCard.
  late StatCard2Model statCardModel1;
  // Model for StatCard.
  late StatCard2Model statCardModel2;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    statCardModel1 = createModel(context, () => StatCard2Model());
    statCardModel2 = createModel(context, () => StatCard2Model());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    statCardModel1.dispose();
    statCardModel2.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
  }
}
