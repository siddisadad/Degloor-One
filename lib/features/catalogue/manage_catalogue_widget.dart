import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/components/modern/modern_product_list_item.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/shop.dart';
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
  List<CatalogProduct> _products = [];
  List<ProductCategory> _businessCategories = [];
  bool _loading = true;
  Shop? _business;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageCatalogueModel());
    _model.productNameTextController ??= TextEditingController();
    _model.productPriceTextController ??= TextEditingController();
    _model.productCategoryTextController ??= TextEditingController();
    _model.stockQuantityTextController ??= TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    final currentUser = currentUserUid;
    if (currentUser == '') {
      setState(() => _loading = false);
      return;
    }
    try {
      final shop = await BusinessService.instance.requireOwned(currentUser);
      _business = shop;
      await _fetchProducts();
      final categories = await BusinessService.instance.productCategories(currentUser);
      setState(() { _businessCategories = categories; });
    } catch (e) {
      AppLogger.error('Error fetching business', e);
      setState(() { _business = null; _loading = false; });
    }
  }

  Future<void> _fetchProducts() async {
    if (_business == null) return;
    setState(() => _loading = true);
    try {
      final products = await BusinessService.instance.products(currentUserUid);
      setState(() { _products = products; _loading = false; });
    } catch (e) {
      AppLogger.error('Error fetching products', e);
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img == null) return;
    setState(() => _model.isUploading = true);
    try {
      final bytes = await img.readAsBytes();
      final url = await BusinessService.instance.uploadPublicImage(folder: 'products', businessId: _business!.id, bytes: bytes);
      setState(() { _model.uploadedImageUrl = url; _model.isUploading = false; });
    } catch (e) {
      setState(() => _model.isUploading = false);
    }
  }

  Future<void> _addProduct() async {
    if (_business == null) return;
    final name = _model.productNameTextController.text;
    final priceStr = _model.productPriceTextController.text;
    if (name.isEmpty || priceStr.isEmpty) return;
    final price = double.tryParse(priceStr);
    if (price == null) return;
    final stock = int.tryParse(_model.stockQuantityTextController.text) ?? 0;

    setState(() => _loading = true);
    try {
      await BusinessService.instance.addProduct(
        userId: currentUserUid,
        name: name,
        price: price,
        categoryName: _model.productCategoryTextController.text,
        imageUrl: _model.uploadedImageUrl,
        stockQuantity: stock,
        trackInventory: _model.trackInventory,
      );
      _model.productNameTextController?.clear();
      _model.productPriceTextController?.clear();
      _model.productCategoryTextController?.clear();
      _model.stockQuantityTextController?.clear();
      _model.uploadedImageUrl = null;
      await _fetchProducts();
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: DegloorTheme.background,
      appBar: degloorAppBar(context, title: 'Manage Catalogue'),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _business == null && !_loading
                ? EmptyStateView(icon: Icons.storefront_outlined, title: 'No shop yet', description: 'Register your business first.', buttonText: 'Register', onTap: () => context.pushNamed('BusinessRegistration'))
                : Column(
                    children: [
                      _buildAddForm(),
                      const SizedBox(height: 24),
                      Expanded(child: _buildList()),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DegloorTheme.radiusMD)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Product', style: DegloorTheme.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  _imagePickerBox(),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: _model.productNameTextController, decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Fresh Milk'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _model.productPriceTextController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (₹)'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _model.stockQuantityTextController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Initial Stock'))),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _model.productCategoryTextController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g. Dairy',
                ),
              ),
              if (_businessCategories.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in _businessCategories)
                      ActionChip(
                        label: Text(category.name),
                        onPressed: () {
                          _model.productCategoryTextController?.text =
                              category.name;
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              FFButtonWidget(
                onPressed: _addProduct,
                text: 'Add to Catalogue',
                options: FFButtonOptions(width: double.infinity, height: 44, color: DegloorTheme.primary, borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePickerBox() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: DegloorTheme.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: DegloorTheme.border)),
        child: _model.isUploading ? const Center(child: CircularProgressIndicator()) : (_model.uploadedImageUrl != null ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_model.uploadedImageUrl!, fit: BoxFit.cover)) : const Icon(Icons.add_a_photo_rounded, color: DegloorTheme.textSecondary)),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_products.isEmpty) return const EmptyStateView(icon: Icons.inventory_2_outlined, title: 'No products yet', description: 'Add your first item above.');
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = _products[index];
        return ModernProductListItem(
          name: p.name,
          price: p.price ?? 0.0,
          imageUrl: p.imageUrl,
          stockQuantity: p.stockQuantity,
          trackInventory: p.trackInventory ?? false,
          actionLabel: 'Edit',
          onActionPressed: () => _editProduct(p),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: DegloorTheme.error),
            onPressed: () => _deleteProduct(p.id),
          ),
        );
      },
    );
  }

  Future<void> _deleteProduct(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Delete Product?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red)))]));
    if (confirm != true) return;
    setState(() => _loading = true);
    await BusinessService.instance.deleteProduct(userId: currentUserUid, productId: id);
    await _fetchProducts();
  }

  Future<void> _editProduct(CatalogProduct product) async {
    final nameC = TextEditingController(text: product.name);
    final priceC = TextEditingController(text: product.price.toString());
    final stockC = TextEditingController(text: (product.stockQuantity ?? 0).toString());
    bool trackInv = product.trackInventory ?? false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setMod) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit Product', style: DegloorTheme.headingMedium),
            const SizedBox(height: 20),
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Product Name')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: priceC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: stockC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock'))),
            ]),
            SwitchListTile(title: const Text('Track Inventory'), value: trackInv, onChanged: (v) => setMod(() => trackInv = v)),
            const SizedBox(height: 24),
            FFButtonWidget(
              onPressed: () async {
                await BusinessService.instance.updateProduct(userId: currentUserUid, productId: product.id, name: nameC.text, price: double.parse(priceC.text), stockQuantity: int.parse(stockC.text), trackInventory: trackInv);
                if (context.mounted) Navigator.pop(context);
                await _fetchProducts();
              },
              text: 'Save Changes',
              options: FFButtonOptions(height: 50, color: DegloorTheme.primary, borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      )),
    );
  }
}
