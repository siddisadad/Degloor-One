import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
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

  Future<BusinessesRow> insertBusiness(Map<String, dynamic> data) {
    return BusinessesTable().insert(data);
  }

  Future<void> updateBusiness({
    required String businessId,
    required String ownerId,
    required Map<String, dynamic> data,
  }) async {
    await BusinessesTable().update(
      data: data,
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

  Future<ProductsRow> insertProduct(Map<String, dynamic> data) {
    return ProductsTable().insert(data);
  }

  Future<void> updateProduct({
    required String productId,
    required String businessId,
    required Map<String, dynamic> data,
  }) async {
    await ProductsTable().update(
      data: data,
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

  Future<ProductCategoriesRow> insertProductCategory(
    Map<String, dynamic> data,
  ) {
    return ProductCategoriesTable().insert(data);
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
