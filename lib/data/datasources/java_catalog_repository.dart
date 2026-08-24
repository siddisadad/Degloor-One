import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_shop_repository.dart';
import 'package:degloor_one/data/repositories/catalog_repository.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/catalog_product_draft.dart';
import 'package:degloor_one/shared/catalog_product_stock.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/shared/product_category_draft.dart';
import 'package:degloor_one/shared/shop_hours.dart';

/// Owner catalogue and hours through the Java API.
class JavaCatalogRepository implements CatalogRepository {
  JavaCatalogRepository({JavaApiClient? client})
      : _client = client ?? JavaApiClient.instance;

  final JavaApiClient _client;

  Map<String, dynamic> _productBody({
    required String businessId,
    required CatalogProductDraft draft,
    String? categoryId,
    bool? available,
    int? stockQuantity,
  }) {
    return {
      'businessId': businessId,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      'name': draft.name.trim(),
      'price': draft.price,
      if (draft.imageUrl != null) 'imageUrl': draft.imageUrl,
      'available': available ?? true,
      'stockQuantity': stockQuantity ?? draft.stock.quantity,
      'trackInventory': draft.trackInventory,
    };
  }

  @override
  Future<List<CatalogProduct>> productsFor(String businessId) async {
    if (businessId.isEmpty) return const [];
    final data = await _client.get(
      '/api/v1/businesses/$businessId/products',
      query: {'availableOnly': 'false'},
    );
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => CatalogProduct.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<CatalogProduct?> productForBusiness({
    required String businessId,
    required String productId,
  }) async {
    if (businessId.isEmpty || productId.isEmpty) return null;
    try {
      final data = await _client.get('/api/v1/products/$productId');
      final product =
          CatalogProduct.fromJson(Map<String, dynamic>.from(data as Map));
      if (product.businessId != businessId) return null;
      return product;
    } on JavaApiException catch (error) {
      if (error.code.contains('404') || error.code.contains('NOT_FOUND')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<CatalogProduct> insertProduct({
    required CatalogProductDraft draft,
    required String businessId,
    String? categoryId,
  }) async {
    final data = await _client.post(
      '/api/v1/products',
      _productBody(
        businessId: businessId,
        draft: draft,
        categoryId: categoryId,
      ),
    );
    return CatalogProduct.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<void> updateProduct({
    required String productId,
    required String businessId,
    required CatalogProductDraft draft,
  }) async {
    await _client.put(
      '/api/v1/products/$productId',
      _productBody(
        businessId: businessId,
        draft: draft,
      ),
    );
  }

  @override
  Future<void> updateStock({
    required String productId,
    required String businessId,
    required CatalogProductStock stock,
  }) async {
    final existing = await productForBusiness(
      businessId: businessId,
      productId: productId,
    );
    if (existing == null) return;
    await _client.put('/api/v1/products/$productId', {
      'businessId': businessId,
      if (existing.categoryId != null) 'categoryId': existing.categoryId,
      'name': existing.name,
      'price': existing.price ?? 0,
      if (existing.imageUrl != null) 'imageUrl': existing.imageUrl,
      'available': existing.isAvailable ?? true,
      'stockQuantity': stock.quantity,
      'trackInventory': existing.trackInventory ?? false,
    });
  }

  @override
  Future<void> deleteProduct({
    required String productId,
    required String businessId,
  }) async {
    await _client.delete('/api/v1/products/$productId');
  }

  @override
  Future<List<ProductCategory>> productCategoriesFor(String businessId) async {
    if (businessId.isEmpty) return const [];
    final data =
        await _client.get('/api/v1/businesses/$businessId/product-categories');
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => ProductCategory.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<ProductCategory> insertProductCategory(
    ProductCategoryDraft draft,
  ) async {
    final data = await _client.post(
      '/api/v1/businesses/${draft.businessId}/product-categories',
      {'name': draft.name},
    );
    return ProductCategory.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<List<ShopHours>> hoursFor(String businessId) async {
    if (businessId.isEmpty) return const [];
    try {
      final data = await _client.get('/api/v1/businesses/$businessId');
      return JavaShopRepository.hoursFromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } on JavaApiException catch (error) {
      if (error.code == 'BUSINESS_NOT_FOUND' || error.code.contains('404')) {
        return const [];
      }
      rethrow;
    }
  }

  @override
  Future<void> upsertHours(
    List<ShopHours> hours, {
    required String businessId,
  }) async {
    final data = await _client.get('/api/v1/businesses/$businessId');
    final shop = Map<String, dynamic>.from(data as Map);
    await _client.put('/api/v1/businesses/$businessId', {
      'name': shop['name'],
      if (shop['ownerName'] != null) 'ownerName': shop['ownerName'],
      if (shop['description'] != null) 'description': shop['description'],
      if (shop['categoryId'] != null) 'categoryId': shop['categoryId'],
      if (shop['cityId'] != null) 'cityId': shop['cityId'],
      if (shop['addressText'] != null) 'addressText': shop['addressText'],
      if (shop['whatsappNumber'] != null) 'whatsappNumber': shop['whatsappNumber'],
      if (shop['phoneNumber'] != null) 'phoneNumber': shop['phoneNumber'],
      if (shop['latitude'] != null) 'latitude': shop['latitude'],
      if (shop['longitude'] != null) 'longitude': shop['longitude'],
      if (shop['open'] != null) 'open': shop['open'],
      if (shop['imageUrl'] != null) 'imageUrl': shop['imageUrl'],
      'hours': [for (final hour in hours) hour.toHoursRequestJson()],
    });
  }
}
