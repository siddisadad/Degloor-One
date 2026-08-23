import 'package:degloor_one/features/catalogue/product_detail_widget.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'business_catalogue_model.dart';
export 'business_catalogue_model.dart';

class BusinessCatalogueWidget extends StatefulWidget {
  const BusinessCatalogueWidget({super.key, required this.businessId});
  final String businessId;

  static String routeName = 'BusinessCatalogue';
  static String routePath = '/businessCatalogue';

  @override
  State<BusinessCatalogueWidget> createState() => _BusinessCatalogueWidgetState();
}

class _BusinessCatalogueWidgetState extends State<BusinessCatalogueWidget> with TickerProviderStateMixin {
  late BusinessCatalogueModel _model;
  TabController? _tabController;
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessCatalogueModel());
    _fetchData();
    _fetchCartCount();
  }

  Future<void> _fetchCartCount() async {
    final count = await CartService.getCartItemCount();
    if (mounted) {
      setState(() {
        _cartItemCount = count;
      });
    }
  }

  Future<void> _fetchData() async {
    try {
      final catalog = await ShopService.instance.catalog(widget.businessId);

      setState(() {
        _model.allProducts = catalog.products;
        _model.categories = catalog.categories;
        _model.groupedProducts = catalog.grouped;
        _model.isLoading = false;

        final tabsCount = catalog.categories
                .where((c) => catalog.grouped.containsKey(c.id))
                .length +
            (catalog.grouped.containsKey('Uncategorized') ? 1 : 0);
        if (tabsCount > 0) {
          _tabController = TabController(length: tabsCount, vsync: this);
        }
      });
    } catch (e) {
      AppLogger.error('Error fetching catalogue', e);
      setState(() => _model.isLoading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_model.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_model.allProducts.isEmpty) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: degloorBackButton(
            context,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
          title: Text(
            'Products',
            style: FlutterFlowTheme.of(context).headlineSmall,
          ),
          elevation: 0,
        ),
        body: const EmptyStateView(
          icon: Icons.inventory_2_outlined,
          title: 'No products yet',
          description: 'This Degloor shop has not listed items yet.',
        ),
      );
    }

    final catList = _model.categories.where((c) => _model.groupedProducts.containsKey(c.id)).toList();
    final hasUncategorized = _model.groupedProducts.containsKey('Uncategorized');

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: degloorBackButton(
          context,
          color: FlutterFlowTheme.of(context).primaryText,
        ),
        title: Text(
          'Products',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
        actions: [
          Stack(
            children: [
              FlutterFlowIconButton(
                icon: Icon(Icons.shopping_cart_rounded, color: FlutterFlowTheme.of(context).primaryText),
                onPressed: () async {
                  await context.pushNamed('ShoppingCart');
                  _fetchCartCount();
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_cartItemCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: _tabController == null ? null : TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: FlutterFlowTheme.of(context).primary,
          unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
          indicatorColor: FlutterFlowTheme.of(context).primary,
          tabs: [
            ...catList.map((c) => Tab(text: c.name)),
            if (hasUncategorized) const Tab(text: 'Others'),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _tabController == null
              ? const Center(child: Text('No products found'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    ...catList.map((c) =>
                        _buildProductList(_model.groupedProducts[c.id]!)),
                    if (hasUncategorized)
                      _buildProductList(
                          _model.groupedProducts['Uncategorized']!),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildProductList(List<CatalogProduct> products) {
    return ListView.separated(
      padding: const EdgeInsets.all(DegloorTheme.spacingMD),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        final inStock = (product.trackInventory != true) || ((product.stockQuantity ?? 0) > 0);

        return InkWell(
          onTap: () {
            context.pushNamed(
              ProductDetailWidget.routeName,
              pathParameters: {'productId': product.id},
            );
          },
          borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
              border: Border.all(color: DegloorTheme.border),
              boxShadow: DegloorTheme.softShadow,
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
                      child: product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: DegloorTheme.accent,
                              child: const Icon(Icons.image_not_supported_rounded, color: DegloorTheme.textSecondary),
                            ),
                    ),
                    if (!inStock)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
                        ),
                        child: const Center(
                          child: Text(
                            'OUT OF STOCK',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: DegloorTheme.titleMedium.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      if (product.description != null && product.description!.isNotEmpty)
                        Text(
                          product.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DegloorTheme.bodySmall,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${product.price?.toStringAsFixed(0)}',
                                style: DegloorTheme.headingMedium.copyWith(color: DegloorTheme.primary, fontSize: 18),
                              ),
                              if (inStock)
                                Text(
                                  'In Stock',
                                  style: DegloorTheme.labelSmall.copyWith(color: DegloorTheme.success),
                                ),
                            ],
                          ),
                          if (inStock)
                            ElevatedButton(
                              onPressed: () async {
                                await CartService.addToCart(
                                  context: context,
                                  businessId: widget.businessId,
                                  productId: product.id,
                                );
                                _fetchCartCount();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DegloorTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                minimumSize: const Size(0, 36),
                              ),
                              child: const Text('Add'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
