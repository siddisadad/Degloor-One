import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'manage_orders_widget.dart' show ManageOrdersWidget;
import 'package:flutter/material.dart';

class ManageOrdersModel extends FlutterFlowModel<ManageOrdersWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
