import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:degloor_one/core/error_handler.dart';
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
  List<ProductCategoriesRow> _businessCategories = [];
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchBusinessCategories() async {
    if (_business == null) return;
    try {
      final categories = await ProductCategoriesTable().queryRows(
        queryFn: (q) => q.eq('business_id', _business!.id).order('name'),
      );
      setState(() {
        _businessCategories = categories;
      });
    } catch (e) {
      AppLogger.error('Error fetching product categories', e);
    }
  }

  Future<void> _fetchData() async {
    final currentUser = currentUserUid;
    if (currentUser == '') {
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
        await _fetchBusinessCategories();
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      AppLogger.error('Error fetching business', e);
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchProducts() async {
    if (_business == null) return;
    setState(() => _loading = true);
    try {
      final products = await ProductsTable().queryRows(
        queryFn: (q) => q.eq('business_id', _business!.id).order('created_at', ascending: false),
      );
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      AppLogger.error('Error fetching products', e);
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    setState(() => _model.isUploading = true);
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'products/${_business!.id}/$fileName';
      final bytes = await image.readAsBytes();

      await SupaFlow.client.storage.from('product-images').uploadBinary(path, bytes);
      final url = SupaFlow.client.storage.from('product-images').getPublicUrl(path);

      setState(() {
        _model.uploadedImageUrl = url;
        _model.isUploading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
      setState(() => _model.isUploading = false);
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
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final price = double.tryParse(priceStr);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid price format')),
      );
      return;
    }

    final stock = int.tryParse(stockStr) ?? 0;

    setState(() => _loading = true);
    try {
      String? categoryId;
      if (categoryName.isNotEmpty) {
        final normalizedName = categoryName.trim().toLowerCase();
        final existingCategories = await ProductCategoriesTable().queryRows(
          queryFn: (q) => q
              .eq('business_id', _business!.id)
              .ilike('name', normalizedName),
        );
        if (existingCategories.isNotEmpty) {
          categoryId = existingCategories.first.id;
        } else {
          final newCategory = await ProductCategoriesTable().insert({
            'business_id': _business!.id,
            'name': normalizedName,
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
        'image_url': _model.uploadedImageUrl,
        'is_available': true,
        'stock_quantity': stock,
        'track_inventory': _model.trackInventory,
        'created_at': DateTime.now().toIso8601String(),
      });

      _model.productNameTextController?.clear();
      _model.productPriceTextController?.clear();
      _model.productCategoryTextController?.clear();
      _model.stockQuantityTextController?.clear();
      _model.trackInventory = false;
      _model.uploadedImageUrl = null;

      await _fetchProducts();
      await _fetchBusinessCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product added successfully'),
            backgroundColor: FlutterFlowTheme.of(context).success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product: $e'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating stock: $e')),
        );
      }
    }
  }

  Future<void> _editProduct(ProductsRow product) async {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final stockController = TextEditingController(text: (product.stockQuantity ?? 0).toString());
    bool trackInv = product.trackInventory ?? false;
    String? currentImageUrl = product.imageUrl;
    bool isEditingUploading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Edit Product', style: FlutterFlowTheme.of(context).headlineSmall),
                const SizedBox(height: 16),
                Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 120,
                          height: 120,
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          child: isEditingUploading
                              ? const Center(child: CircularProgressIndicator())
                              : currentImageUrl != null
                                  ? CachedRemoteImage(url: currentImageUrl!)
                                  : const Icon(Icons.image_not_supported_rounded, size: 40),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: FlutterFlowIconButton(
                          borderRadius: 20,
                          buttonSize: 40,
                          fillColor: FlutterFlowTheme.of(context).primary,
                          icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final XFile? img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                            if (img != null) {
                              setModalState(() => isEditingUploading = true);
                              try {
                                final b = await img.readAsBytes();
                                final ext = img.path.split('.').last;
                                final path = 'products/${_business!.id}/edit_${DateTime.now().millisecondsSinceEpoch}.$ext';
                                await SupaFlow.client.storage.from('product-images').uploadBinary(path, b);
                                final url = SupaFlow.client.storage.from('product-images').getPublicUrl(path);
                                setModalState(() {
                                  currentImageUrl = url;
                                  isEditingUploading = false;
                                });
                              } catch (e) {
                                setModalState(() => isEditingUploading = false);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price (₹)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Stock'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Track Inventory'),
                  value: trackInv,
                  onChanged: (v) => setModalState(() => trackInv = v),
                ),
                const SizedBox(height: 20),
                FFButtonWidget(
                  onPressed: () async {
                    final price = double.tryParse(priceController.text);
                    final stock = int.tryParse(stockController.text) ?? 0;
                    if (price == null) return;

                    await ProductsTable().update(
                      data: {
                        'name': nameController.text,
                        'price': price,
                        'stock_quantity': stock,
                        'track_inventory': trackInv,
                        'image_url': currentImageUrl,
                      },
                      matchingRows: (q) => q.eq('id', product.id),
                    );
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    await _fetchProducts();
                  },
                  text: 'Save Changes',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: const TextStyle(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
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
          title: Text(
            'Manage Catalogue',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(),
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_business == null && !_loading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New Product',
                                  style: FlutterFlowTheme.of(context).titleMedium,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: _pickImage,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                                        ),
                                        child: _model.isUploading
                                            ? const Center(child: CircularProgressIndicator())
                                            : _model.uploadedImageUrl != null
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: CachedRemoteImage(url: _model.uploadedImageUrl!),
                                                  )
                                                : Icon(Icons.add_a_photo_rounded, color: FlutterFlowTheme.of(context).secondaryText),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _model.productNameTextController,
                                        focusNode: _model.productNameFocusNode,
                                        decoration: InputDecoration(
                                          labelText: 'Product Name',
                                          labelStyle: FlutterFlowTheme.of(context).labelMedium,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).alternate,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).primary,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context).bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _model.productPriceTextController,
                                        focusNode: _model.productPriceFocusNode,
                                        decoration: InputDecoration(
                                          labelText: 'Price (₹)',
                                          labelStyle: FlutterFlowTheme.of(context).labelMedium,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).alternate,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).primary,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context).bodyMedium,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                            controller: _model.productCategoryTextController,
                                            focusNode: _model.productCategoryFocusNode,
                                            decoration: InputDecoration(
                                              labelText: 'Category',
                                              labelStyle: FlutterFlowTheme.of(context).labelMedium,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(context).alternate,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(context).primary,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context).bodyMedium,
                                          ),
                                          if (_businessCategories.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  children: _businessCategories.map((c) => Padding(
                                                    padding: const EdgeInsets.only(right: 8.0),
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _model.productCategoryTextController.text = c.name;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: FlutterFlowTheme.of(context).primaryContainer,
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        child: Text(c.name, style: FlutterFlowTheme.of(context).labelSmall),
                                                      ),
                                                    ),
                                                  )).toList(),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _model.stockQuantityTextController,
                                        focusNode: _model.stockQuantityFocusNode,
                                        decoration: InputDecoration(
                                          labelText: 'Initial Stock',
                                          labelStyle: FlutterFlowTheme.of(context).labelMedium,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).alternate,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).primary,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context).bodyMedium,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
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
                                          activeThumbColor: FlutterFlowTheme.of(context).primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                                  child: FFButtonWidget(
                                    onPressed: _addProduct,
                                    text: 'Add to Catalogue',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 44.0,
                                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                        const SizedBox(height: 24.0),
                        Text(
                          'Inventory List',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                        const SizedBox(height: 8.0),
                        if (_loading)
                          const Center(child: CircularProgressIndicator())
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
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      color: FlutterFlowTheme.of(context).primaryBackground,
                                      child: product.imageUrl != null
                                          ? CachedRemoteImage(url: product.imageUrl!)
                                          : Icon(Icons.image_not_supported_rounded, color: FlutterFlowTheme.of(context).alternate),
                                    ),
                                  ),
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
                                      FlutterFlowIconButton(
                                        borderRadius: 20.0,
                                        buttonSize: 40.0,
                                        icon: Icon(
                                          Icons.edit_rounded,
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                          size: 20.0,
                                        ),
                                        onPressed: () => _editProduct(product),
                                      ),
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
                                                title: const Text('Update Stock'),
                                                content: TextField(
                                                  controller: controller,
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(labelText: 'Quantity'),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, controller.text),
                                                    child: const Text('Update'),
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
                                              title: const Text('Delete Product'),
                                              content: const Text('Are you sure you want to delete this product?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Delete'),
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
