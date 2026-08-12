import 'package:degloor_one/components/business_card800502e0/business_card800502e0_widget.dart';
import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/filter_chip/filter_chip_widget.dart';
import 'package:degloor_one/components/text_field/text_field_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'search_results_widget.dart' show SearchResultsWidget;
import 'package:flutter/material.dart';

class SearchResultsModel extends FlutterFlowModel<SearchResultsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for TextField.
  late TextFieldModel textFieldModel;
  // Model for FilterChip.
  late FilterChipModel filterChipModel1;
  // Model for FilterChip.
  late FilterChipModel filterChipModel2;
  // Model for FilterChip.
  late FilterChipModel filterChipModel3;
  // Model for FilterChip.
  late FilterChipModel filterChipModel4;
  // Model for BusinessCard800502e0.
  late BusinessCard800502e0Model businessCard800502e0Model1;
  // Model for BusinessCard800502e0.
  late BusinessCard800502e0Model businessCard800502e0Model2;
  // Model for BusinessCard800502e0.
  late BusinessCard800502e0Model businessCard800502e0Model3;
  // Model for BusinessCard800502e0.
  late BusinessCard800502e0Model businessCard800502e0Model4;
  // Model for BusinessCard800502e0.
  late BusinessCard800502e0Model businessCard800502e0Model5;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    textFieldModel = createModel(context, () => TextFieldModel());
    filterChipModel1 = createModel(context, () => FilterChipModel());
    filterChipModel2 = createModel(context, () => FilterChipModel());
    filterChipModel3 = createModel(context, () => FilterChipModel());
    filterChipModel4 = createModel(context, () => FilterChipModel());
    businessCard800502e0Model1 =
        createModel(context, () => BusinessCard800502e0Model());
    businessCard800502e0Model2 =
        createModel(context, () => BusinessCard800502e0Model());
    businessCard800502e0Model3 =
        createModel(context, () => BusinessCard800502e0Model());
    businessCard800502e0Model4 =
        createModel(context, () => BusinessCard800502e0Model());
    businessCard800502e0Model5 =
        createModel(context, () => BusinessCard800502e0Model());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    textFieldModel.dispose();
    filterChipModel1.dispose();
    filterChipModel2.dispose();
    filterChipModel3.dispose();
    filterChipModel4.dispose();
    businessCard800502e0Model1.dispose();
    businessCard800502e0Model2.dispose();
    businessCard800502e0Model3.dispose();
    businessCard800502e0Model4.dispose();
    businessCard800502e0Model5.dispose();
    buttonModel.dispose();
  }
}
