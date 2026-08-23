import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/catalog_product_draft.dart';
import 'package:degloor_one/shared/catalog_product_stock.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/shared/product_category_draft.dart';
import 'package:degloor_one/shared/shop_draft.dart';
import 'package:degloor_one/shared/shop_hours.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

/// Data access for owner shop, catalogue, and hours. Widgets should go
/// through [BusinessService].
class BusinessRepository {
  Future<List<BusinessesRow>> ownedBy(String userId) {
    if (userId.isEmpty) return Future.value(const []);
    return BusinessesTable().queryRows(
      queryFn: (q) => q.eq('owner_id', userId),
    );
  }

  Future<BusinessesRow?> byId(String businessId) async {
    if (businessId.isEmpty) return null;
    final rows = await BusinessesTable().queryRows(
      queryFn: (q) => q.eq('id', businessId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<BusinessesRow> insertBusiness(
    ShopDraft draft, {
    required String ownerId,
  }) {
    return BusinessesTable().insert(draft.toInsertJson(ownerId: ownerId));
  }

  Future<void> updateBusiness({
    required String businessId,
    required String ownerId,
    required ShopDraft draft,
  }) async {
    await BusinessesTable().update(
      data: draft.toUpdateJson(),
      matchingRows: (q) => q.eq('id', businessId).eq('owner_id', ownerId),
    );
  }

  Future<List<ProductsRow>> productsFor(String businessId) {
    if (businessId.isEmpty) return Future.value(const []);
    return ProductsTable().queryRows(
      queryFn: (q) =>
          q.eq('business_id', businessId).order('created_at', ascending: false),
    );
  }

  Future<ProductsRow?> productForBusiness({
    required String businessId,
    required String productId,
  }) async {
    if (businessId.isEmpty || productId.isEmpty) return null;
    final rows = await ProductsTable().queryRows(
      queryFn: (q) => q.eq('id', productId).eq('business_id', businessId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<CatalogProduct> insertProduct({
    required CatalogProductDraft draft,
    required String businessId,
    String? categoryId,
  }) async {
    final row = await ProductsTable().insert(
      draft.toInsertJson(businessId: businessId, categoryId: categoryId),
    );
    return CatalogProduct.fromRow(row);
  }

  Future<void> updateProduct({
    required String productId,
    required String businessId,
    required CatalogProductDraft draft,
  }) async {
    await ProductsTable().update(
      data: draft.toUpdateJson(),
      matchingRows: (q) => q.eq('id', productId).eq('business_id', businessId),
    );
  }

  Future<void> updateStock({
    required String productId,
    required String businessId,
    required CatalogProductStock stock,
  }) async {
    await ProductsTable().update(
      data: stock.toUpdateJson(),
      matchingRows: (q) => q.eq('id', productId).eq('business_id', businessId),
    );
  }

  Future<void> deleteProduct({
    required String productId,
    required String businessId,
  }) async {
    await ProductsTable().delete(
      matchingRows: (q) => q.eq('id', productId).eq('business_id', businessId),
    );
  }

  Future<List<ProductCategoriesRow>> productCategoriesFor(String businessId) {
    if (businessId.isEmpty) return Future.value(const []);
    return ProductCategoriesTable().queryRows(
      queryFn: (q) => q.eq('business_id', businessId).order('name'),
    );
  }

  Future<ProductCategory> insertProductCategory(
    ProductCategoryDraft draft,
  ) async {
    final row = await ProductCategoriesTable().insert(draft.toInsertJson());
    return ProductCategory.fromRow(row);
  }

  Future<List<BusinessHoursRow>> hoursFor(String businessId) {
    if (businessId.isEmpty) return Future.value(const []);
    return BusinessHoursTable().queryRows(
      queryFn: (q) => q.eq('business_id', businessId).order('day_of_week'),
    );
  }

  Future<void> upsertHours(
    List<ShopHours> hours, {
    required String businessId,
  }) async {
    final rows = [
      for (final hour in hours) hour.toUpsertJson(businessId: businessId),
    ];
    if (kUseShowcaseData) {
      for (final row in rows) {
        final id = row['id'];
        if (id != null) {
          ShowcaseCatalog.update(
            'business_hours',
            row,
            ShowcaseQuery()..eq('id', id),
          );
          continue;
        }
        final existing = ShowcaseCatalog.query(
          'business_hours',
          ShowcaseQuery()
            ..eq('business_id', row['business_id'])
            ..eq('day_of_week', row['day_of_week']),
        );
        if (existing.isNotEmpty) {
          ShowcaseCatalog.update(
            'business_hours',
            row,
            ShowcaseQuery()..eq('id', existing.first['id']),
          );
        } else {
          ShowcaseCatalog.insert('business_hours', row);
        }
      }
      return;
    }
    await BusinessHoursTable().upsert(rows);
  }
}
