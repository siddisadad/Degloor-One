import '/components/action_button/action_button_widget.dart';
import '/components/button/button_widget.dart';
import '/components/photo_item/photo_item_widget.dart';
import '/components/review_card/review_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'business_profile_widget.dart' show BusinessProfileWidget;
import 'package:flutter/material.dart';

class BusinessProfileModel extends FlutterFlowModel<BusinessProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ActionButton.
  late ActionButtonModel actionButtonModel1;
  // Model for ActionButton.
  late ActionButtonModel actionButtonModel2;
  // Model for ActionButton.
  late ActionButtonModel actionButtonModel3;
  // Model for PhotoItem.
  late PhotoItemModel photoItemModel1;
  // Model for PhotoItem.
  late PhotoItemModel photoItemModel2;
  // Model for PhotoItem.
  late PhotoItemModel photoItemModel3;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for ReviewCard.
  late ReviewCardModel reviewCardModel1;
  // Model for ReviewCard.
  late ReviewCardModel reviewCardModel2;
  // Model for Button.
  late ButtonModel buttonModel2;

  Future<List<Map<String, dynamic>>>? reviewsFuture;

  @override
  void initState(BuildContext context) {
    actionButtonModel1 = createModel(context, () => ActionButtonModel());
    actionButtonModel2 = createModel(context, () => ActionButtonModel());
    actionButtonModel3 = createModel(context, () => ActionButtonModel());
    photoItemModel1 = createModel(context, () => PhotoItemModel());
    photoItemModel2 = createModel(context, () => PhotoItemModel());
    photoItemModel3 = createModel(context, () => PhotoItemModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    reviewCardModel1 = createModel(context, () => ReviewCardModel());
    reviewCardModel2 = createModel(context, () => ReviewCardModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    actionButtonModel1.dispose();
    actionButtonModel2.dispose();
    actionButtonModel3.dispose();
    photoItemModel1.dispose();
    photoItemModel2.dispose();
    photoItemModel3.dispose();
    buttonModel1.dispose();
    reviewCardModel1.dispose();
    reviewCardModel2.dispose();
    buttonModel2.dispose();
  }
}
