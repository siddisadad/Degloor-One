import 'dart:async';

import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

class ProductDetailWidget extends StatefulWidget {
  const ProductDetailWidget({super.key, required this.productId});
  final String productId;

  static String routeName = 'ProductDetail';
  static String routePath = '/productDetail/:productId';

  @override
  State<ProductDetailWidget> createState() => _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends State<ProductDetailWidget> {
  Future<CatalogProduct?>? _productFuture;
  int _quantity = 1;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  void _fetchProduct() {
    _productFuture =
        ShopService.instance.productById(widget.productId).then((product) {
      if (product != null) {
        unawaited(
          ShopService.instance.trackEvent(
            businessId: product.businessId,
            eventType: ShopEvents.productView,
            metadata: {'product_id': product.id},
          ),
        );
      }
      return product;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: FutureBuilder<CatalogProduct?>(
          future: _productFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData &&
                snapshot.connectionState != ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  leading: degloorBackButton(
                    context,
                    color: DegloorTheme.textPrimary,
                  ),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }
            final product = snapshot.data;
            if (product == null) {
              return Scaffold(
                backgroundColor: DegloorTheme.background,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  leading: degloorBackButton(
                    context,
                    color: DegloorTheme.textPrimary,
                  ),
                  title: Text('Product', style: DegloorTheme.headingMedium),
                ),
                body: const EmptyStateView(
                  icon: Icons.inventory_2_outlined,
                  title: 'Product not found',
                  description:
                      'This listing is no longer available on DEGLOOR ONE.',
                ),
              );
            }

            final inStock = (product.trackInventory != true) ||
                ((product.stockQuantity ?? 0) > 0);

            return Scaffold(
              backgroundColor: Colors.white,
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 350,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: product.imageUrl != null
                          ? CachedRemoteImage(
                              url: product.imageUrl!,
                              height: 350,
                            )
                          : Container(color: DegloorTheme.accent),
                    ),
                    backgroundColor: Colors.white,
                    automaticallyImplyLeading: false,
                    leading: degloorBackButton(context, color: Colors.black),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(DegloorTheme.spacingLG),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: DegloorTheme.headingLarge),
                          const SizedBox(height: 8),
                          Text(
                            '₹${product.price?.toStringAsFixed(0)}',
                            style: DegloorTheme.headingMedium.copyWith(
                              color: DegloorTheme.primary,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text('Description', style: DegloorTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(
                            product.description ?? 'No description provided.',
                            style: DegloorTheme.bodyLarge.copyWith(
                              color: DegloorTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (product.trackInventory == true) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 18,
                                  color: DegloorTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  inStock
                                      ? '${product.stockQuantity} units available'
                                      : 'Out of stock',
                                  style: DegloorTheme.bodyMedium.copyWith(
                                    color: inStock
                                        ? DegloorTheme.success
                                        : DegloorTheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                          Text('Quantity', style: DegloorTheme.titleMedium),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _quantityButton(Icons.remove, () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              }),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  '$_quantity',
                                  style: DegloorTheme.titleLarge,
                                ),
                              ),
                              _quantityButton(Icons.add, () {
                                setState(() => _quantity++);
                              }),
                            ],
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              bottomSheet: Container(
                padding: const EdgeInsets.all(DegloorTheme.spacingLG),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FFButtonWidget(
                        onPressed: _isAdding || !inStock
                            ? null
                            : () async {
                                setState(() => _isAdding = true);
                                try {
                                  await CartService.addToCart(
                                    context: context,
                                    businessId: product.businessId,
                                    productId: product.id,
                                    quantity: _quantity,
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isAdding = false);
                                  }
                                }
                              },
                        text: _isAdding ? 'Adding...' : 'Add to Cart',
                        options: FFButtonOptions(
                          height: 54,
                          color: DegloorTheme.primary,
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          borderRadius: BorderRadius.circular(
                            DegloorTheme.radiusMD,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: DegloorTheme.border),
          borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
