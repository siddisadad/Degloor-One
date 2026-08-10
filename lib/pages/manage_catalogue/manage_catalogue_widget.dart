import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_catalogue_model.dart';
export 'manage_catalogue_model.dart';

class ManageCatalogueWidget extends StatefulWidget {
  const ManageCatalogueWidget({super.key});

  static String routeName = 'ManageCatalogue';
  static String routePath = '/manageCatalogue';

  @override
  State<ManageCatalogueWidget> createState() => _ManageCatalogueWidgetState();
}

class _ManageCatalogueWidgetState extends State<ManageCatalogueWidget> {
  late ManageCatalogueModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<ProductsRow> _products = [];
  bool _loading = true;
  BusinessesRow? _business;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageCatalogueModel());

    _model.productNameTextController ??= TextEditingController();
    _model.productNameFocusNode ??= FocusNode();

    _model.productPriceTextController ??= TextEditingController();
    _model.productPriceFocusNode ??= FocusNode();

    _model.productCategoryTextController ??= TextEditingController();
    _model.productCategoryFocusNode ??= FocusNode();

    _model.stockQuantityTextController ??= TextEditingController();
    _model.stockQuantityFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    final currentUser = currentUserUid;
    if (currentUser == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final businesses = await BusinessesTable().queryRows(
        queryFn: (q) => q.eq('owner_id', currentUser),
      );

      if (businesses.isNotEmpty) {
        _business = businesses.first;
        await _fetchProducts();
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error fetching business: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchProducts() async {
    if (_business == null) return;
    setState(() => _loading = true);
    try {
      final products = await ProductsTable().queryRows(
        queryFn: (q) => q.eq('business_id', _business!.id),
      );
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _addProduct() async {
    if (_business == null) return;

    final name = _model.productNameTextController.text;
    final priceStr = _model.productPriceTextController.text;
    final categoryName = _model.productCategoryTextController.text;
    final stockStr = _model.stockQuantityTextController.text;

    if (name.isEmpty || priceStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final price = double.tryParse(priceStr);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid price format')),
      );
      return;
    }

    final stock = int.tryParse(stockStr) ?? 0;

    setState(() => _loading = true);
    try {
      String? categoryId;
      if (categoryName.isNotEmpty) {
        final existingCategories = await ProductCategoriesTable().queryRows(
          queryFn: (q) => q
              .eq('business_id', _business!.id)
              .eq('name', categoryName),
        );
        if (existingCategories.isNotEmpty) {
          categoryId = existingCategories.first.id;
        } else {
          final newCategory = await ProductCategoriesTable().insert({
            'business_id': _business!.id,
            'name': categoryName,
            'created_at': DateTime.now().toIso8601String(),
          });
          categoryId = newCategory.id;
        }
      }

      await ProductsTable().insert({
        'business_id': _business!.id,
        'category_id': categoryId,
        'name': name,
        'price': price,
        'is_available': true,
        'stock_quantity': stock,
        'track_inventory': _model.trackInventory,
        'created_at': DateTime.now().toIso8601String(),
      });

      _model.productNameTextController.clear();
      _model.productPriceTextController.clear();
      _model.productCategoryTextController.clear();
      _model.stockQuantityTextController.clear();
      _model.trackInventory = false;

      await _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteProduct(String productId) async {
    setState(() => _loading = true);
    try {
      await ProductsTable().delete(
        matchingRows: (q) => q.eq('id', productId),
      );
      await _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting product: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStock(ProductsRow product, int newStock) async {
    try {
      await ProductsTable().update(
        data: {'stock_quantity': newStock},
        matchingRows: (q) => q.eq('id', product.id),
      );
      await _fetchProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating stock: $e')),
      );
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
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          title: Text(
            'Manage Catalogue',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(),
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (_business == null && !_loading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No business found for this account. Please register your business first.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Add Product Form
                        Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New Product',
                                  style: FlutterFlowTheme.of(context).titleMedium,
                                ),
                                TextFormField(
                                  controller: _model.productNameTextController,
                                  focusNode: _model.productNameFocusNode,
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText: 'Product Name',
                                    labelStyle: FlutterFlowTheme.of(context).labelMedium,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).primary,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                ),
                                SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _model.productPriceTextController,
                                        focusNode: _model.productPriceFocusNode,
                                        autofocus: false,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'Price (₹)',
                                          labelStyle: FlutterFlowTheme.of(context).labelMedium,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).alternate,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).primary,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context).bodyMedium,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _model.productCategoryTextController,
                                        focusNode: _model.productCategoryFocusNode,
                                        autofocus: false,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'Category',
                                          labelStyle: FlutterFlowTheme.of(context).labelMedium,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).alternate,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).primary,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context).bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _model.stockQuantityTextController,
                                        focusNode: _model.stockQuantityFocusNode,
                                        autofocus: false,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'Initial Stock',
                                          labelStyle: FlutterFlowTheme.of(context).labelMedium,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).alternate,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).primary,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context).bodyMedium,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                    Row(
                                      children: [
                                        Text(
                                          'Track Inventory',
                                          style: FlutterFlowTheme.of(context).bodySmall,
                                        ),
                                        Switch(
                                          value: _model.trackInventory,
                                          onChanged: (newValue) {
                                            setState(() => _model.trackInventory = newValue);
                                          },
                                          activeColor: FlutterFlowTheme.of(context).primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                                  child: FFButtonWidget(
                                    onPressed: _addProduct,
                                    text: 'Add to Catalogue',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 44.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                      color: FlutterFlowTheme.of(context).primary,
                                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                            font: GoogleFonts.inter(),
                                            color: Colors.white,
                                          ),
                                      elevation: 2.0,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24.0),
                        Text(
                          'Inventory List',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                        SizedBox(height: 8.0),
                        if (_loading)
                          Center(child: CircularProgressIndicator())
                        else if (_products.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                'No products in catalogue yet.',
                                style: FlutterFlowTheme.of(context).labelMedium,
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.separated(
                              itemCount: _products.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                return ListTile(
                                  title: Text(
                                    product.name,
                                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                                          font: GoogleFonts.inter(),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₹${product.price}',
                                        style: FlutterFlowTheme.of(context).labelMedium.override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(context).primary,
                                            ),
                                      ),
                                      Text(
                                        product.trackInventory == true
                                            ? 'Stock: ${product.stockQuantity ?? 0}'
                                            : 'Unlimited',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.inter(),
                                              color: (product.trackInventory == true && (product.stockQuantity ?? 0) <= 0)
                                                  ? FlutterFlowTheme.of(context).error
                                                  : FlutterFlowTheme.of(context).secondaryText,
                                            ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (product.trackInventory == true)
                                        FlutterFlowIconButton(
                                          borderRadius: 20.0,
                                          buttonSize: 40.0,
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            final controller = TextEditingController(text: product.stockQuantity.toString());
                                            final newStockStr = await showDialog<String>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Update Stock'),
                                                content: TextField(
                                                  controller: controller,
                                                  keyboardType: TextInputType.number,
                                                  decoration: InputDecoration(labelText: 'Quantity'),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, controller.text),
                                                    child: Text('Update'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (newStockStr != null) {
                                              final newStock = int.tryParse(newStockStr);
                                              if (newStock != null) {
                                                await _updateStock(product, newStock);
                                              }
                                            }
                                          },
                                        ),
                                      FlutterFlowIconButton(
                                        borderRadius: 20.0,
                                        buttonSize: 40.0,
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: FlutterFlowTheme.of(context).error,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Delete Product'),
                                              content: Text('Are you sure you want to delete this product?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await _deleteProduct(product.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
