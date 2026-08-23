import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/shared/placed_order.dart';
import 'package:degloor_one/shared/shop.dart';
import 'order_tracking_widget.dart' show OrderTrackingWidget;
import 'package:flutter/material.dart';

class OrderTrackingModel extends FlutterFlowModel<OrderTrackingWidget> {
  ///  State fields for stateful widgets in this page.

  // Future for the order details
  Future<List<PlacedOrder>>? orderFuture;
  // Future for order items
  Future<List<OrderItemsRow>>? orderItemsFuture;
  // Future for status history
  Future<List<OrderStatusHistoryRow>>? historyFuture;
  // Future for business info
  Future<List<Shop>>? businessFuture;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
