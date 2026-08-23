import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/business_card/business_card_widget.dart';
import 'package:degloor_one/components/category_item/category_item_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'customer_home_widget.dart' show CustomerHomeWidget;
import 'package:flutter/material.dart';

class CustomerHomeModel extends FlutterFlowModel<CustomerHomeWidget> {
  ///  State fields for stateful widgets in this page.

  Future<List<UsersRow>>? userProfileFuture;
  Future<List<BusinessesRow>>? openNowBusinessesFuture;
  Future<List<ProductsRow>>? recommendedProductsFuture;
  String locationName = 'Degloor, Maharashtra';
  bool openNow = false;

  // Model for CategoryItem.
  late CategoryItemModel categoryItemModel1;
  // Model for CategoryItem.
  late CategoryItemModel categoryItemModel2;
  // Model for CategoryItem.
  late CategoryItemModel categoryItemModel3;
  // Model for CategoryItem.
  late CategoryItemModel categoryItemModel4;
  // Model for CategoryItem.
  late CategoryItemModel categoryItemModel5;
  // Model for CategoryItem.
  late CategoryItemModel categoryItemModel6;
  // Model for BusinessCard.
  late BusinessCardModel businessCardModel1;
  // Model for BusinessCard.
  late BusinessCardModel businessCardModel2;
  // Model for BusinessCard.
  late BusinessCardModel businessCardModel3;
  // Model for BusinessCard.
  late BusinessCardModel businessCardModel4;
  // Model for BusinessCard.
  late BusinessCardModel businessCardModel5;

  @override
  void initState(BuildContext context) {
    categoryItemModel1 = createModel(context, () => CategoryItemModel());
    categoryItemModel2 = createModel(context, () => CategoryItemModel());
    categoryItemModel3 = createModel(context, () => CategoryItemModel());
    categoryItemModel4 = createModel(context, () => CategoryItemModel());
    categoryItemModel5 = createModel(context, () => CategoryItemModel());
    categoryItemModel6 = createModel(context, () => CategoryItemModel());
    businessCardModel1 = createModel(context, () => BusinessCardModel());
    businessCardModel2 = createModel(context, () => BusinessCardModel());
    businessCardModel3 = createModel(context, () => BusinessCardModel());
    businessCardModel4 = createModel(context, () => BusinessCardModel());
    businessCardModel5 = createModel(context, () => BusinessCardModel());
  }

  @override
  void dispose() {
    categoryItemModel1.dispose();
    categoryItemModel2.dispose();
    categoryItemModel3.dispose();
    categoryItemModel4.dispose();
    categoryItemModel5.dispose();
    categoryItemModel6.dispose();
    businessCardModel1.dispose();
    businessCardModel2.dispose();
    businessCardModel3.dispose();
    businessCardModel4.dispose();
    businessCardModel5.dispose();
  }
}
