import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/address_service.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:flutter/material.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'cart_model.dart';
export 'cart_model.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({
    super.key,
    this.showBack = true,
  });

  /// Pushed cart (profile, catalogue) shows back. The Cart tab does not.
  final bool showBack;

  static String routeName = 'Cart';
  static String routePath = '/cart';
  static String stackedRouteName = 'ShoppingCart';
  static String stackedRoutePath = '/shoppingCart';

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

      final shops = await DiscoveryService.instance.businessesByIds([
        _model.currentCart!.businessId,
      ]);
      if (shops.isNotEmpty) {
        _model.currentBusiness = shops.first;
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
    if (userId == '') {
      if (!mounted) return;
      setState(() {
        _model.addressesFuture = Future.value([]);
        _model.selectedAddress = null;
      });
      return;
    }
    try {
      final addresses = await AddressService.instance.listForUser(userId);
      if (!mounted) return;
      setState(() {
        _model.addressesFuture = Future.value(addresses);
        _model.selectedAddress = AddressService.pickDefault(addresses);
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
      final fee = await AddressService.instance.deliveryFee(
        userId: currentUserUid,
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

  Future<void> _placeOrder(List<CartLine> items) async {
    if (_model.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a delivery address')));
      return;
    }

    setState(() => _model.isPlacingOrder = true);
    try {
      await AddressService.instance.requireForUser(
        userId: currentUserUid,
        id: _model.selectedAddress!.id,
      );
      final orderId = await OrderService.instance.placeOrderFromCart(
        userId: currentUserUid,
        businessId: _model.currentCart!.businessId,
        addressId: _model.selectedAddress!.id,
        cartId: _model.currentCart!.id,
        items: items,
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
      backgroundColor: DegloorTheme.background,
      appBar: degloorAppBar(
        context,
        title: 'Your Cart',
        showBack: widget.showBack,
      ),
      body: FutureBuilder<List<CartLine>>(
        future: _model.cartItemsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) {
            return EmptyStateView(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              description: 'Add items from nearby shops and they will appear here.',
              buttonText: 'Browse shops',
              onTap: () => context.goNamed('CustomerHome'),
            );
          }

          final subtotal = CartService.subtotal(items);

          return Column(
            children: [
              if (_model.currentBusiness != null)
                Container(
                  width: double.infinity,
                  color: DegloorTheme.primary.withValues(alpha: 0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: DegloorTheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ordering from ${_model.currentBusiness!.name}',
                          style: DegloorTheme.titleMedium.copyWith(color: DegloorTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(DegloorTheme.spacingMD),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final product = item.product;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
                        boxShadow: DegloorTheme.softShadow,
                        border: Border.all(color: DegloorTheme.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
                            child: Container(
                              width: 70,
                              height: 70,
                              color: DegloorTheme.accent,
                              child: product?.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: product!.imageUrl!,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      memCacheWidth: memCachePx(context, 70),
                                      memCacheHeight: memCachePx(context, 70),
                                      placeholder: (_, __) =>
                                          Container(color: DegloorTheme.accent),
                                      errorWidget: (_, __, ___) => const Icon(
                                        Icons.image_not_supported_rounded,
                                        color: DegloorTheme.textSecondary,
                                      ),
                                    )
                                  : const Icon(Icons.image_not_supported_rounded, color: DegloorTheme.textSecondary),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product?.name ?? 'Item',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: DegloorTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${product?.price ?? 0}',
                                  style: DegloorTheme.bodyLarge.copyWith(
                                    color: DegloorTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: DegloorTheme.background,
                              borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
                            ),
                            child: Row(
                              children: [
                                _qtyBtn(Icons.remove, () => _updateQuantity(item.id, item.quantity - 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('${item.quantity}', style: DegloorTheme.titleMedium),
                                ),
                                _qtyBtn(Icons.add, () => _updateQuantity(item.id, item.quantity + 1)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Checkout Summary
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(DegloorTheme.radiusXL)),
                ),
                padding: const EdgeInsets.all(DegloorTheme.spacingLG),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Address
                    InkWell(
                      onTap: () async {
                         await context.pushNamed('AddressList');
                         _fetchAddresses();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DegloorTheme.background,
                          borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: DegloorTheme.secondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Deliver to', style: DegloorTheme.labelSmall),
                                  Text(
                                    _model.selectedAddress?.addressText ?? 'Select delivery address',
                                    style: DegloorTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: DegloorTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _summaryRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    _summaryRow(
                      'Delivery Fee',
                      _model.deliveryFee == 0 ? 'FREE' : '₹${_model.deliveryFee.toStringAsFixed(0)}',
                      valueColor: _model.deliveryFee == 0 ? DegloorTheme.success : null,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: DegloorTheme.headingMedium),
                        Text(
                          '₹${(subtotal + _model.deliveryFee).toStringAsFixed(0)}',
                          style: DegloorTheme.headingMedium.copyWith(color: DegloorTheme.primary, fontSize: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _model.isPlacingOrder
                          ? null
                          : () => _placeOrder(items),
                      style: FilledButton.styleFrom(
                        backgroundColor: DegloorTheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            DegloorTheme.primary.withValues(alpha: 0.5),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DegloorTheme.radiusMD),
                        ),
                      ),
                      child: Text(
                        _model.isPlacingOrder
                            ? 'Processing...'
                            : 'Place Order (COD)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: DegloorTheme.primary),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: DegloorTheme.bodyMedium.copyWith(color: DegloorTheme.textSecondary)),
        Text(
          value,
          style: DegloorTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? DegloorTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
