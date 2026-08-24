import 'package:degloor_one/backend/repositories/business_repository.dart';
import 'package:degloor_one/data/datasources/supabase_shop_maps.dart';
import 'package:degloor_one/data/repositories/catalog_repository.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/catalog_product_draft.dart';
import 'package:degloor_one/shared/catalog_product_stock.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/shared/product_category_draft.dart';
import 'package:degloor_one/shared/shop_hours.dart';

/// Showcase or live table access for owner catalogue and hours.
class SupabaseCatalogRepository implements CatalogRepository {
  SupabaseCatalogRepository({BusinessRepository? inner})
      : _inner = inner ?? BusinessRepository();

  final BusinessRepository _inner;

  @override
  Future<List<CatalogProduct>> productsFor(String businessId) async {
    final rows = await _inner.productsFor(businessId);
    return rows.map(catalogProductFromRow).toList();
  }

  @override
  Future<CatalogProduct?> productForBusiness({
    required String businessId,
    required String productId,
  }) async {
    final row = await _inner.productForBusiness(
      businessId: businessId,
      productId: productId,
    );
    return row == null ? null : catalogProductFromRow(row);
  }

  @override
  Future<CatalogProduct> insertProduct({
    required CatalogProductDraft draft,
    required String businessId,
    String? categoryId,
  }) {
    return _inner.insertProduct(
      draft: draft,
      businessId: businessId,
      categoryId: categoryId,
    );
  }

  @override
  Future<void> updateProduct({
    required String productId,
    required String businessId,
    required CatalogProductDraft draft,
  }) {
    return _inner.updateProduct(
      productId: productId,
      businessId: businessId,
      draft: draft,
    );
  }

  @override
  Future<void> updateStock({
    required String productId,
    required String businessId,
    required CatalogProductStock stock,
  }) {
    return _inner.updateStock(
      productId: productId,
      businessId: businessId,
      stock: stock,
    );
  }

  @override
  Future<void> deleteProduct({
    required String productId,
    required String businessId,
  }) {
    return _inner.deleteProduct(
      productId: productId,
      businessId: businessId,
    );
  }

  @override
  Future<List<ProductCategory>> productCategoriesFor(String businessId) async {
    final rows = await _inner.productCategoriesFor(businessId);
    return rows.map(productCategoryFromRow).toList();
  }

  @override
  Future<ProductCategory> insertProductCategory(ProductCategoryDraft draft) {
    return _inner.insertProductCategory(draft);
  }

  @override
  Future<List<ShopHours>> hoursFor(String businessId) async {
    final rows = await _inner.hoursFor(businessId);
    return rows.map(shopHoursFromRow).toList();
  }

  @override
  Future<void> upsertHours(
    List<ShopHours> hours, {
    required String businessId,
  }) {
    return _inner.upsertHours(hours, businessId: businessId);
  }
}
