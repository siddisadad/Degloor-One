import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CartModel());
    _fetchCartData();
    _fetchAddresses();
  }

  Future<void> _fetchCartData() async {
    final userId = currentUserUid;
    if (userId == '') return;

    try {
      final carts = await CartsTable().queryRows(queryFn: (q) => q.eq('user_id', userId));
      if (carts.isEmpty) {
        setState(() {
          _model.cartItemsFuture = Future.value([]);
          _model.currentCart = null;
        });
        return;
      }

      _model.currentCart = carts.first;

      // Fetch Business details
      final business = await BusinessesTable().querySingleRow(queryFn: (q) => q.eq('id', _model.currentCart!.businessId));
      if (business.isNotEmpty) {
        _model.currentBusiness = business.first;
      }

      final items = await SupaFlow.client
          .from('cart_items')
          .select('*, products(*)')
          .eq('cart_id', _model.currentCart!.id);

      setState(() {
        _model.cartItemsFuture = Future.value(List<Map<String, dynamic>>.from(items));
      });
    } catch (e) {
      print('Error fetching cart: $e');
    }
  }

  Future<void> _fetchAddresses() async {
    final userId = currentUserUid;
    if (userId == '') return;
    final addresses = await AddressesTable().queryRows(queryFn: (q) => q.eq('user_id', userId));
    setState(() {
      _model.addressesFuture = Future.value(addresses);
      if (addresses.isNotEmpty) {
        _model.selectedAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
      }
    });
  }

  Future<void> _updateQuantity(String itemId, int newQty) async {
    if (newQty <= 0) {
      await CartItemsTable().delete(matchingRows: (q) => q.eq('id', itemId));
    } else {
      await CartItemsTable().update(data: {'quantity': newQty}, matchingRows: (q) => q.eq('id', itemId));
    }
    _fetchCartData();
  }

  Future<void> _placeOrder(List<Map<String, dynamic>> items, double total) async {
    if (_model.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a delivery address')));
      return;
    }

    setState(() => _model.isPlacingOrder = true);
    try {
      // 1. Create Order
      final order = await OrdersTable().insert({
        'user_id': currentUserUid,
        'business_id': _model.currentCart!.businessId,
        'total_amount': total,
        'status': 'pending',
        'payment_status': 'unpaid',
        'delivery_address_id': _model.selectedAddress!.id,
        'payment_method': 'COD',
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2. Create Order Items
      for (var item in items) {
        final product = item['products'] as Map<String, dynamic>;
        await OrderItemsTable().insert({
          'order_id': order.id,
          'product_id': product['id'],
          'quantity': item['quantity'],
          'price_at_purchase': (product['price'] as num).toDouble(),
        });
      }

      // 3. Clear Cart
      await CartsTable().delete(matchingRows: (q) => q.eq('id', _model.currentCart!.id));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully!'), backgroundColor: Colors.green));

      // Navigate to order success or tracking
      context.goNamed('CustomerHome');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to place order: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _model.isPlacingOrder = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: true,
        title: Text('Your Cart', style: FlutterFlowTheme.of(context).headlineSmall),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _model.cartItemsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: FlutterFlowTheme.of(context).alternate),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: FlutterFlowTheme.of(context).titleMedium),
                  const SizedBox(height: 24),
                  FFButtonWidget(
                    onPressed: () => context.goNamed('CustomerHome'),
                    text: 'Start Shopping',
                    options: FFButtonOptions(
                      width: 200,
                      height: 44,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ],
              ),
            );
          }

          double subtotal = 0;
          for (var item in items) {
            final price = (item['products']['price'] as num).toDouble();
            subtotal += price * (item['quantity'] as int);
          }

          return Column(
            children: [
              if (_model.currentBusiness != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.store_rounded, color: FlutterFlowTheme.of(context).primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Ordering from ${_model.currentBusiness!.name}',
                           style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final product = item['products'] as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 60,
                              height: 60,
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              child: product['image_url'] != null
                                  ? Image.network(product['image_url'], fit: BoxFit.cover)
                                  : Icon(Icons.image_not_supported_rounded, color: FlutterFlowTheme.of(context).alternate),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product['name'], style: FlutterFlowTheme.of(context).bodyLarge.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                                Text('₹${product['price']}', style: FlutterFlowTheme.of(context).labelMedium.override(font: GoogleFonts.inter(), color: FlutterFlowTheme.of(context).primary)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded),
                                onPressed: () => _updateQuantity(item['id'], (item['quantity'] as int) - 1),
                              ),
                              Text('${item['quantity']}', style: FlutterFlowTheme.of(context).bodyMedium),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline_rounded),
                                onPressed: () => _updateQuantity(item['id'], (item['quantity'] as int) + 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Address Selection
                      InkWell(
                        onTap: () async {
                           await context.pushNamed('AddressList');
                           _fetchAddresses();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: FlutterFlowTheme.of(context).secondaryText),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Deliver to', style: FlutterFlowTheme.of(context).labelSmall),
                                  Text(_model.selectedAddress?.addressText ?? 'Select Address',
                                       style: FlutterFlowTheme.of(context).bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_right_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: FlutterFlowTheme.of(context).bodyLarge),
                          Text('₹$subtotal', style: FlutterFlowTheme.of(context).titleMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Fee', style: FlutterFlowTheme.of(context).bodyMedium),
                          const Text('₹0', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: FlutterFlowTheme.of(context).headlineSmall),
                          Text('₹$subtotal', style: FlutterFlowTheme.of(context).headlineSmall.override(font: GoogleFonts.inter(fontWeight: FontWeight.w800, color: FlutterFlowTheme.of(context).primary))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FFButtonWidget(
                        onPressed: _model.isPlacingOrder ? null : () => _placeOrder(items, subtotal),
                        text: 'Place Order (COD)',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 54,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
