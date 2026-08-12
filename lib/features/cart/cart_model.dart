import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'cart_widget.dart' show CartWidget;
import 'package:flutter/material.dart';

class CartModel extends FlutterFlowModel<CartWidget> {
  ///  State fields for stateful widgets in this page.

  // Future to load cart items and addresses
  Future<List<Map<String, dynamic>>>? cartItemsFuture;
  Future<List<AddressesRow>>? addressesFuture;
  CartsRow? currentCart;
  BusinessesRow? currentBusiness;
  bool isPlacingOrder = false;

  // Selected address for the order
  AddressesRow? selectedAddress;

  // Selected payment method
  String selectedPaymentMethod = 'COD';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
