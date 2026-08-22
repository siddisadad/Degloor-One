import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:degloor_one/core/error_handler.dart';
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
      final carts = await CartService.cartsForUser(userId);
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

      if (kUseShowcaseData) {
        setState(() {
          _model.cartItemsFuture = Future.value(
            ShowcaseCatalog.cartItemsWithProducts(_model.currentCart!.id),
          );
        });
        return;
      }
      final items = await SupaFlow.client
          .from('cart_items')
          .select('*, products(*)')
          .eq('cart_id', _model.currentCart!.id);

      setState(() {
        _model.cartItemsFuture = Future.value(List<Map<String, dynamic>>.from(items));
      });
    } catch (e) {
      AppLogger.error('Error fetching cart', e);
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
    _updateDeliveryFee();
  }

  Future<void> _updateDeliveryFee() async {
    if (_model.currentBusiness != null && _model.selectedAddress != null) {
      final fee = await OrdersTable().calculateDeliveryFee(
        businessId: _model.currentBusiness!.id,
        addressId: _model.selectedAddress!.id,
      );
      setState(() {
        _model.deliveryFee = fee;
      });
    }
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
      // Use secure RPC for order placement and inventory management
      final List<Map<String, dynamic>> rpcItems = items.map((item) {
        final product = item['products'] as Map<String, dynamic>;
        return {
          'product_id': product['id'],
          'quantity': item['quantity'],
          'price': (product['price'] as num).toDouble(),
        };
      }).toList();

      if (kUseShowcaseData) {
        final order = OrderService.placeShowcaseOrder(
          userId: currentUserUid,
          businessId: _model.currentCart!.businessId,
          cartId: _model.currentCart!.id,
          addressId: _model.selectedAddress!.id,
          totalAmount: total,
          deliveryFee: _model.deliveryFee,
          items: rpcItems,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.goNamed(
          'OrderSuccess',
          queryParameters: {
            'orderId': serializeParam(order['id'], ParamType.string),
          }.withoutNulls,
        );
        return;
      }
      final response = await SupaFlow.client.rpc(
        'place_order',
        params: {
          'p_business_id': _model.currentCart!.businessId,
          'p_total_amount': total,
          'p_delivery_address_id': _model.selectedAddress!.id,
          'p_payment_method': 'COD',
          'p_items': rpcItems,
        },
      );

      if (response == null) {
        throw Exception('Failed to place order (no response from server)');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to order success
      context.goNamed(
        'OrderSuccess',
        queryParameters: {
          'orderId': serializeParam(response, ParamType.string),
        }.withoutNulls,
      );
    } catch (e) {
      AppLogger.error('Failed to place order', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        title: Text(
          'Your cart',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 22,
              ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _model.cartItemsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) {
            return EmptyStateView(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              description: 'Add milk, rice, or anything nearby and check out in a tap.',
              buttonText: 'Browse shops',
              onTap: () => context.goNamed('CustomerHome'),
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
                                  ? CachedNetworkImage(
                                      imageUrl: product['image_url'],
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Icon(
                                        Icons.image_not_supported_rounded,
                                        color: FlutterFlowTheme.of(context).alternate,
                                      ),
                                    )
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
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
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
                          Text('₹${_model.deliveryFee.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: _model.deliveryFee == 0 ? Colors.green : FlutterFlowTheme.of(context).primaryText,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: FlutterFlowTheme.of(context).headlineSmall),
                          Text('₹${(subtotal + _model.deliveryFee).toStringAsFixed(2)}',
                              style: FlutterFlowTheme.of(context).headlineSmall.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.w800, color: FlutterFlowTheme.of(context).primary))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FFButtonWidget(
                        onPressed: _model.isPlacingOrder ? null : () => _placeOrder(items, subtotal + _model.deliveryFee),
                        text: _model.isPlacingOrder ? 'Placing order...' : 'Place Order (COD)',
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
