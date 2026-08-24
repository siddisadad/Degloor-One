import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/catalog_product_draft.dart';
import 'package:degloor_one/shared/catalog_product_stock.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/shared/product_category_draft.dart';
import 'package:degloor_one/shared/shop_hours.dart';

/// Owner catalogue and hours writes. Widgets go through [BusinessService].
abstract class CatalogRepository {
  Future<List<CatalogProduct>> productsFor(String businessId);

  Future<CatalogProduct?> productForBusiness({
    required String businessId,
    required String productId,
  });

  Future<CatalogProduct> insertProduct({
    required CatalogProductDraft draft,
    required String businessId,
    String? categoryId,
  });

  Future<void> updateProduct({
    required String productId,
    required String businessId,
    required CatalogProductDraft draft,
  });

  Future<void> updateStock({
    required String productId,
    required String businessId,
    required CatalogProductStock stock,
  });

  Future<void> deleteProduct({
    required String productId,
    required String businessId,
  });

  Future<List<ProductCategory>> productCategoriesFor(String businessId);

  Future<ProductCategory> insertProductCategory(ProductCategoryDraft draft);

  Future<List<ShopHours>> hoursFor(String businessId);

  Future<void> upsertHours(
    List<ShopHours> hours, {
    required String businessId,
  });
}
