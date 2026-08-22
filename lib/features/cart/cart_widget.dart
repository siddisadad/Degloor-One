import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/shared/otp_copy.dart';
import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:degloor_one/core/error_handler.dart';
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
    if (userId == '') {
      if (!mounted) return;
      setState(() {
        _model.cartItemsFuture = Future.value([]);
        _model.currentCart = null;
      });
      return;
    }

    try {
      final carts = await CartService.cartsForUser(userId);
      if (carts.isEmpty) {
        if (!mounted) return;
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

      final items = await CartService.itemsForCart(_model.currentCart!.id);
      if (!mounted) return;
      setState(() {
        _model.cartItemsFuture = Future.value(items);
      });
    } catch (e) {
      AppLogger.error('Error fetching cart', e);
      if (!mounted) return;
      setState(() {
        _model.cartItemsFuture = Future.value([]);
      });
    }
  }

  Future<void> _fetchAddresses() async {
    final userId = currentUserUid;
    if (userId == '') return;
    try {
      final addresses = await AddressesTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId),
      );
      if (!mounted) return;
      setState(() {
        _model.addressesFuture = Future.value(addresses);
        if (addresses.isNotEmpty) {
          _model.selectedAddress = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
        }
      });
      await _updateDeliveryFee();
    } catch (e) {
      AppLogger.error('Error fetching addresses', e);
      if (!mounted) return;
      setState(() {
        _model.addressesFuture = Future.value([]);
      });
    }
  }

  Future<void> _updateDeliveryFee() async {
    if (_model.currentBusiness == null || _model.selectedAddress == null) {
      return;
    }
    try {
      final fee = await OrdersTable().calculateDeliveryFee(
        businessId: _model.currentBusiness!.id,
        addressId: _model.selectedAddress!.id,
      );
      if (!mounted) return;
      setState(() {
        _model.deliveryFee = fee;
      });
    } catch (e) {
      AppLogger.error('Error calculating delivery fee', e);
    }
  }

  Future<void> _updateQuantity(String itemId, int newQty) async {
    try {
      await CartService.updateQuantity(itemId: itemId, quantity: newQty);
      await _fetchCartData();
    } catch (e) {
      AppLogger.event(
        'CART_QTY_FAILED',
        fields: {'item_id': itemId, 'quantity': newQty},
        error: e,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLogger.userFacingMessage(
              e,
              fallback: 'Unable to update the cart. Please try again.',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _placeOrder(List<Map<String, dynamic>> items) async {
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

      final orderId = await OrderService.instance.placeOrder(
        userId: currentUserUid,
        businessId: _model.currentCart!.businessId,
        addressId: _model.selectedAddress!.id,
        cartId: _model.currentCart!.id,
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
          'orderId': serializeParam(orderId, ParamType.string),
        }.withoutNulls,
      );
    } catch (e) {
      AppLogger.event(
        'ORDER_CREATE_FAILED',
        fields: {
          'user_id': currentUserUid,
          'cart_id': _model.currentCart?.id,
        },
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLogger.userFacingMessage(
                e,
                fallback: 'Unable to place the order. Please try again.',
              ),
            ),
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
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.store_rounded, color: FlutterFlowTheme.of(context).primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ordering from ${_model.currentBusiness!.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final product = item['products'] as Map<String, dynamic>;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 64,
                              height: 64,
                              color: FlutterFlowTheme.of(context).primaryBackground,
                              child: product['image_url'] != null
                                  ? CachedRemoteImage(url: product['image_url'] as String)
                                  : Icon(Icons.image_not_supported_rounded, color: FlutterFlowTheme.of(context).alternate),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${product['name']}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${product['price']}',
                                  style: FlutterFlowTheme.of(context).labelMedium.override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context).primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
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
                          Text(
                            '₹$subtotal',
                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
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
                          Text(
                            '₹${(subtotal + _model.deliveryFee).toStringAsFixed(2)}',
                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        OtpCopy.checkoutHint,
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                      const SizedBox(height: 16),
                      FFButtonWidget(
                        onPressed: _model.isPlacingOrder ? null : () => _placeOrder(items),
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
