import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      final products = await ProductsTable().queryRows(
        queryFn: (q) => q.eq('business_id', widget.businessId).eq('is_available', true),
      );
      final categories = await ProductCategoriesTable().queryRows(
        queryFn: (q) => q.eq('business_id', widget.businessId),
      );

      final grouped = <String, List<ProductsRow>>{};
      for (var p in products) {
        final catId = p.categoryId ?? 'Uncategorized';
        grouped.putIfAbsent(catId, () => []).add(p);
      }

      setState(() {
        _model.allProducts = products;
        _model.categories = categories;
        _model.groupedProducts = grouped;
        _model.isLoading = false;

        final tabsCount = categories.length + (grouped.containsKey('Uncategorized') ? 1 : 0);
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
        appBar: AppBar(title: const Text('Catalogue')),
        body: const Center(child: Text('No products available for this business.')),
      );
    }

    final catList = _model.categories.where((c) => _model.groupedProducts.containsKey(c.id)).toList();
    final hasUncategorized = _model.groupedProducts.containsKey('Uncategorized');

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
                  await context.pushNamed('Cart');
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
      body: _tabController == null
        ? const Center(child: Text('No products found'))
        : TabBarView(
            controller: _tabController,
            children: [
              ...catList.map((c) => _buildProductList(_model.groupedProducts[c.id]!)),
              if (hasUncategorized) _buildProductList(_model.groupedProducts['Uncategorized']!),
            ],
          ),
    );
  }

  Widget _buildProductList(List<ProductsRow> products) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: FlutterFlowTheme.of(context).secondaryBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: FlutterFlowTheme.of(context).alternate),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    child: product.imageUrl != null
                        ? CachedRemoteImage(url: product.imageUrl!)
                        : Icon(Icons.image_not_supported_rounded, color: FlutterFlowTheme.of(context).alternate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product.price}',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          color: FlutterFlowTheme.of(context).primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (product.trackInventory == true)
                        Text(
                          (product.stockQuantity ?? 0) > 0 ? 'In Stock' : 'Out of Stock',
                          style: FlutterFlowTheme.of(context).labelSmall.override(
                            fontFamily: GoogleFonts.inter().fontFamily,
                            color: (product.stockQuantity ?? 0) > 0 ? FlutterFlowTheme.of(context).success : FlutterFlowTheme.of(context).error,
                          ),
                        ),
                    ],
                  ),
                ),
                FFButtonWidget(
                  onPressed: (product.trackInventory == true && (product.stockQuantity ?? 0) <= 0)
                      ? null
                      : () async {
                          await CartService.addToCart(
                            context: context,
                            businessId: widget.businessId,
                            productId: product.id,
                          );
                          _fetchCartCount();
                        },
                  text: 'Add',
                  options: FFButtonOptions(
                    width: 70,
                    height: 36,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    borderRadius: BorderRadius.circular(18),
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
