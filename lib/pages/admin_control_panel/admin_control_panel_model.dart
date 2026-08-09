import '/components/action_item/action_item_widget.dart';
import '/components/button/button_widget.dart';
import '/components/category_chip/category_chip_widget.dart';
import '/components/stat_card2/stat_card2_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
  // Model for ActionItem.
  late ActionItemModel actionItemModel1;
  // Model for ActionItem.
  late ActionItemModel actionItemModel2;
  // Model for ActionItem.
  late ActionItemModel actionItemModel3;
  // Model for Button.
  late ButtonModel buttonModel2;
  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel1;
  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel2;
  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel3;
  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel4;
  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel5;
  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel6;
  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel7;

  @override
  void initState(BuildContext context) {
    statCardModel1 = createModel(context, () => StatCard2Model());
    statCardModel2 = createModel(context, () => StatCard2Model());
    buttonModel1 = createModel(context, () => ButtonModel());
    actionItemModel1 = createModel(context, () => ActionItemModel());
    actionItemModel2 = createModel(context, () => ActionItemModel());
    actionItemModel3 = createModel(context, () => ActionItemModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    categoryChipModel1 = createModel(context, () => CategoryChipModel());
    categoryChipModel2 = createModel(context, () => CategoryChipModel());
    categoryChipModel3 = createModel(context, () => CategoryChipModel());
    categoryChipModel4 = createModel(context, () => CategoryChipModel());
    categoryChipModel5 = createModel(context, () => CategoryChipModel());
    categoryChipModel6 = createModel(context, () => CategoryChipModel());
    categoryChipModel7 = createModel(context, () => CategoryChipModel());
  }

  @override
  void dispose() {
    statCardModel1.dispose();
    statCardModel2.dispose();
    buttonModel1.dispose();
    actionItemModel1.dispose();
    actionItemModel2.dispose();
    actionItemModel3.dispose();
    buttonModel2.dispose();
    categoryChipModel1.dispose();
    categoryChipModel2.dispose();
    categoryChipModel3.dispose();
    categoryChipModel4.dispose();
    categoryChipModel5.dispose();
    categoryChipModel6.dispose();
    categoryChipModel7.dispose();
  }
}
