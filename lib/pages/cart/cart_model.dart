import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'cart_widget.dart' show CartWidget;
import 'package:flutter/material.dart';

class CartModel extends FlutterFlowModel<CartWidget> {
  ///  State fields for stateful widgets in this page.

  // Future to load cart items and addresses
  Future<List<CartItemsRow>>? cartItemsFuture;
  Future<List<AddressesRow>>? addressesFuture;

  // Selected address for the order
  AddressesRow? selectedAddress;

  // Selected payment method
  String selectedPaymentMethod = 'COD';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
