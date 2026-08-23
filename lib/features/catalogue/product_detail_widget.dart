import 'package:flutter/material.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/cart_service.dart';
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
  Future<ProductsRow?>? _productFuture;
  int _quantity = 1;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  void _fetchProduct() {
    _productFuture = ProductsTable().querySingleRow(
      queryFn: (q) => q.eq('id', widget.productId),
    ).then((rows) => rows.isNotEmpty ? rows.first : null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductsRow?>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final product = snapshot.data;
        if (product == null) {
          return const Scaffold(body: Center(child: Text('Product not found')));
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: product.imageUrl != null
                      ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                      : Container(color: DegloorTheme.accent),
                ),
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
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
                        style: DegloorTheme.bodyLarge.copyWith(color: DegloorTheme.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      if (product.trackInventory == true) ...[
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 18, color: DegloorTheme.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              (product.stockQuantity ?? 0) > 0 
                                ? '${product.stockQuantity} units available' 
                                : 'Out of stock',
                              style: DegloorTheme.bodyMedium.copyWith(
                                color: (product.stockQuantity ?? 0) > 0 ? DegloorTheme.success : DegloorTheme.error,
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
                            if (_quantity > 1) setState(() => _quantity--);
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text('$_quantity', style: DegloorTheme.titleLarge),
                          ),
                          _quantityButton(Icons.add, () {
                            setState(() => _quantity++);
                          }),
                        ],
                      ),
                      const SizedBox(height: 100), // Spacing for sticky bottom
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
                    onPressed: _isAdding || ((product.trackInventory ?? false) && (product.stockQuantity ?? 0) <= 0)
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
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isAdding = false);
                        }
                      },
                    text: _isAdding ? 'Adding...' : 'Add to Cart',
                    options: FFButtonOptions(
                      height: 54,
                      color: DegloorTheme.primary,
                      textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
