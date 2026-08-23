import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/saved_address.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shopping_cart.dart';
import 'cart_widget.dart' show CartWidget;
import 'package:flutter/material.dart';

class CartModel extends FlutterFlowModel<CartWidget> {
  ///  State fields for stateful widgets in this page.

  // Future to load cart items and addresses
  Future<List<CartLine>>? cartItemsFuture;
  Future<List<SavedAddress>>? addressesFuture;
  ShoppingCart? currentCart;
  Shop? currentBusiness;
  bool isPlacingOrder = false;

  // Selected address for the order
  SavedAddress? selectedAddress;
  double deliveryFee = 0.0;

  // Selected payment method
  String selectedPaymentMethod = 'COD';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
