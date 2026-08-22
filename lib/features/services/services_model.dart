import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'services_widget.dart' show ServicesWidget;
import 'package:flutter/material.dart';

class ServicesModel extends FlutterFlowModel<ServicesWidget> {
  ///  State fields for stateful widgets in this page.

  Future<List<ServiceCategoriesRow>>? categoriesFuture;
  List<dynamic> providers = [];
  bool providersLoading = false;
  bool providersHasMore = true;
  int providersOffset = 0;

  String? selectedCategoryId;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
