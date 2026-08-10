import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_model.dart';
export 'cart_model.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({super.key});

  static String routeName = 'Cart';
  static String routePath = '/cart';

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  late CartModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<CartsRow> _carts = [];
  List<CartItemsRow> _cartItems = [];
  Map<String, ProductsRow> _products = {};
  List<AddressesRow> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CartModel());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = currentUserUid;
      if (user == null) return;

      // Load Carts
      _carts = await CartsTable().queryRows(
        queryFn: (q) => q.eq('user_id', user),
      );

      if (_carts.isNotEmpty) {
        final cartIds = _carts.map((c) => c.id).toList();
        // Load Cart Items
        _cartItems = await CartItemsTable().queryRows(
          queryFn: (q) => q.inFilter('cart_id', cartIds),
        );

        if (_cartItems.isNotEmpty) {
          final productIds = _cartItems.map((i) => i.productId).toSet().toList();
          // Load Products
          final productList = await ProductsTable().queryRows(
            queryFn: (q) => q.inFilter('id', productIds),
          );
          _products = {for (var p in productList) p.id: p};
        }
      }

      // Load Addresses
      _addresses = await AddressesTable().queryRows(
        queryFn: (q) => q.eq('user_id', user),
      );
      if (_addresses.isNotEmpty && _model.selectedAddress == null) {
        _model.selectedAddress = _addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => _addresses.first,
        );
      }
    } catch (e) {
      print('Error loading cart data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get subtotal {
    double total = 0;
    for (var item in _cartItems) {
      final product = _products[item.productId];
      if (product != null && product.price != null) {
        total += product.price! * item.quantity;
      }
    }
    return total;
  }

  double get deliveryFee => _cartItems.isEmpty ? 0 : 20.0;
  double get total => subtotal + deliveryFee;

  Future<void> _updateQuantity(CartItemsRow item, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeItem(item);
      return;
    }
    try {
      await CartItemsTable().update(
        data: {'quantity': newQuantity},
        matchingRows: (q) => q.eq('id', item.id),
      );
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating quantity: $e')),
      );
    }
  }

  Future<void> _removeItem(CartItemsRow item) async {
    try {
      await CartItemsTable().delete(
        matchingRows: (q) => q.eq('id', item.id),
      );
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item: $e')),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (_cartItems.isEmpty) return;
    if (_model.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    if (_model.selectedPaymentMethod == 'UPI') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('UPI Payment (Simulation)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('In a real app, this would open your UPI app to pay ₹$total.'),
              SizedBox(height: 16),
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Simulating payment...'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Success (Simulated)'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    setState(() => _isLoading = true);
    try {
      final user = currentUserUid;
      // We'll create one order per cart
      for (var cart in _carts) {
        final itemsForThisCart = _cartItems.where((i) => i.cartId == cart.id).toList();
        if (itemsForThisCart.isEmpty) continue;

        double cartTotal = 0;
        for (var item in itemsForThisCart) {
          final product = _products[item.productId];
          if (product != null && product.price != null) {
            cartTotal += product.price! * item.quantity;
          }
        }
        cartTotal += 20.0;

        final deliveryOtp = (math.Random().nextInt(9000) + 1000).toString();

        // 1. Create order
        final newOrder = await OrdersTable().insert({
          'user_id': user,
          'business_id': cart.businessId,
          'total_amount': cartTotal,
          'status': 'Pending',
          'payment_status': _model.selectedPaymentMethod == 'UPI' ? 'Paid' : 'Pending',
          'delivery_address_id': _model.selectedAddress!.id,
          'payment_method': _model.selectedPaymentMethod,
          'delivery_otp': deliveryOtp,
        });

        // 1b. Insert initial status history
        await OrderStatusHistoryTable().insert({
          'order_id': newOrder.id,
          'status': 'Pending',
          'notes': 'Order placed by customer.',
        });

        // 2. Move items to order_items
        for (var item in itemsForThisCart) {
          final product = _products[item.productId];
          await OrderItemsTable().insert({
            'order_id': newOrder.id,
            'product_id': item.productId,
            'quantity': item.quantity,
            'price_at_purchase': product?.price ?? 0.0,
          });

          if (product != null && product.trackInventory == true) {
            final currentStock = product.stockQuantity ?? 0;
            await ProductsTable().update(
              data: {'stock_quantity': currentStock - item.quantity},
              matchingRows: (q) => q.eq('id', product.id),
            );
          }

          // 3. Delete cart item
          await CartItemsTable().delete(matchingRows: (q) => q.eq('id', item.id));
        }

        // 4. Delete cart if empty? Actually _addToCart creates it if missing.
        // For now just clearing items is enough.
      }

      // 5. Send Notification
      await NotificationsTable().insert({
        'user_id': user,
        'title': 'Order Placed Successfully',
        'message': 'Your order has been placed and is waiting for business confirmation.',
        'type': 'order_status',
        'is_read': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );

      context.goNamed('CustomerHome');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'My Cart',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              )
            : _cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                        SizedBox(height: 24),
                        FFButtonWidget(
                          onPressed: () => context.goNamed('CustomerHome'),
                          text: 'Browse Businesses',
                          options: FFButtonOptions(
                            width: 200,
                            height: 40,
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.inter(),
                                  color: Colors.white,
                                ),
                            elevation: 2,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(24, 16, 24, 8),
                              child: Text(
                                'Items',
                                style: FlutterFlowTheme.of(context).titleMedium,
                              ),
                            ),
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _cartItems.length,
                              itemBuilder: (context, index) {
                                final item = _cartItems[index];
                                final product = _products[item.productId];
                                if (product == null) return Container();

                                return Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(24, 8, 24, 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context).alternate,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                            child: Image.network(
                                              product.imageUrl ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&h=300&q=80',
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                      ),
                                                ),
                                                Text(
                                                  '₹${product.price}',
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        font: GoogleFonts.inter(),
                                                        color: FlutterFlowTheme.of(context).primary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.remove_circle_outline, size: 20),
                                                    onPressed: () => _updateQuantity(item, item.quantity - 1),
                                                  ),
                                                  Text(
                                                    '${item.quantity}',
                                                    style: FlutterFlowTheme.of(context).bodyMedium,
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.add_circle_outline, size: 20),
                                                    onPressed: () => _updateQuantity(item, item.quantity + 1),
                                                  ),
                                                ],
                                              ),
                                              InkWell(
                                                onTap: () => _removeItem(item),
                                                child: Text(
                                                  'Remove',
                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                        font: GoogleFonts.inter(),
                                                        color: FlutterFlowTheme.of(context).error,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 8),
                              child: Text(
                                'Select Delivery Address',
                                style: FlutterFlowTheme.of(context).titleMedium,
                              ),
                            ),
                            if (_addresses.isEmpty)
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(24, 8, 24, 8),
                                child: Text('No addresses found. Please add one in profile.'),
                              )
                            else
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(24, 8, 24, 8),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<AddressesRow>(
                                      value: _model.selectedAddress,
                                      isExpanded: true,
                                      items: _addresses.map((addr) {
                                        return DropdownMenuItem(
                                          value: addr,
                                          child: Text(addr.title ?? addr.addressText ?? 'Address'),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() => _model.selectedAddress = val);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 8),
                              child: Text(
                                'Payment Method',
                                style: FlutterFlowTheme.of(context).titleMedium,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(24, 8, 24, 8),
                              child: Column(
                                children: [
                                  RadioListTile<String>(
                                    title: Text('Cash on Delivery (COD)'),
                                    value: 'COD',
                                    groupValue: _model.selectedPaymentMethod,
                                    onChanged: (val) {
                                      setState(() => _model.selectedPaymentMethod = val!);
                                    },
                                    activeColor: FlutterFlowTheme.of(context).primary,
                                  ),
                                  RadioListTile<String>(
                                    title: Text('UPI (PhonePe, Google Pay, etc.)'),
                                    value: 'UPI',
                                    groupValue: _model.selectedPaymentMethod,
                                    onChanged: (val) {
                                      setState(() => _model.selectedPaymentMethod = val!);
                                    },
                                    activeColor: FlutterFlowTheme.of(context).primary,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Color(0x33000000),
                              offset: Offset(0, -2),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Subtotal', style: FlutterFlowTheme.of(context).bodyMedium),
                                  Text('₹$subtotal', style: FlutterFlowTheme.of(context).bodyMedium),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Delivery Fee', style: FlutterFlowTheme.of(context).bodyMedium),
                                  Text('₹$deliveryFee', style: FlutterFlowTheme.of(context).bodyMedium),
                                ],
                              ),
                              Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                        ),
                                  ),
                                  Text(
                                    '₹$total',
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              FFButtonWidget(
                                onPressed: _placeOrder,
                                text: 'Place Order',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 50,
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                        font: GoogleFonts.inter(),
                                        color: Colors.white,
                                      ),
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
