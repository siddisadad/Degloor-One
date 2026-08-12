import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'customer_orders_widget.dart' show CustomerOrdersWidget;
import 'package:flutter/material.dart';

class CustomerOrdersModel extends FlutterFlowModel<CustomerOrdersWidget> {
  ///  State fields for stateful widgets in this page.

  Future<List<OrdersRow>>? ordersFuture;
  Map<String, BusinessesRow> businesses = {};

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
