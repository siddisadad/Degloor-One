import 'package:degloor_one/backend/supabase/supabase.dart';

/// Public shop reads and customer review/report writes. Widgets should go
/// through [ShopService].
class ShopRepository {
  Future<BusinessesRow?> byId(String businessId) async {
    if (businessId.isEmpty) return null;
    final rows = await BusinessesTable().queryRows(
      queryFn: (q) => q.eq('id', businessId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<BusinessCategoriesRow?> categoryById(String categoryId) async {
    if (categoryId.isEmpty) return null;
    final rows = await BusinessCategoriesTable().queryRows(
      queryFn: (q) => q.eq('id', categoryId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<BusinessHoursRow>> hoursFor(String businessId) {
    if (businessId.isEmpty) return Future.value(const []);
    return BusinessHoursTable().queryRows(
      queryFn: (q) => q.eq('business_id', businessId).order('day_of_week'),
    );
  }

  Future<Map<String, List<BusinessHoursRow>>> hoursForMany(
    List<String> businessIds,
  ) async {
    final ids = businessIds.where((id) => id.isNotEmpty).toSet().toList();
    if (ids.isEmpty) return {};
    final rows = await BusinessHoursTable().queryRows(
      queryFn: (q) =>
          q.inFilter('business_id', ids).order('day_of_week'),
    );
    final map = {for (final id in ids) id: <BusinessHoursRow>[]};
    for (final row in rows) {
      final id = row.businessId;
      if (id == null || id.isEmpty) continue;
      map.putIfAbsent(id, () => []).add(row);
    }
    return map;
  }

  Future<List<ProductsRow>> availableProducts(String businessId) {
    if (businessId.isEmpty) return Future.value(const []);
    return ProductsTable().queryRows(
      queryFn: (q) =>
          q.eq('business_id', businessId).eq('is_available', true),
    );
  }

  Future<ProductsRow?> productById(String productId) async {
    if (productId.isEmpty) return null;
    final rows = await ProductsTable().queryRows(
      queryFn: (q) => q.eq('id', productId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<BusinessAnalyticsRow> insertAnalytics(Map<String, dynamic> data) {
    return BusinessAnalyticsTable().insert(data);
  }

  Future<List<ProductCategoriesRow>> productCategories(String businessId) {
    if (businessId.isEmpty) return Future.value(const []);
    return ProductCategoriesTable().queryRows(
      queryFn: (q) => q.eq('business_id', businessId).order('name'),
    );
  }

  Future<List<ReviewsRow>> reviewsFor(String businessId) {
    if (businessId.isEmpty) return Future.value(const []);
    return ReviewsTable().queryRows(
      queryFn: (q) =>
          q.eq('business_id', businessId).order('created_at', ascending: false),
    );
  }

  Future<ReviewsRow?> reviewByUser({
    required String userId,
    required String businessId,
  }) async {
    if (userId.isEmpty || businessId.isEmpty) return null;
    final rows = await ReviewsTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId).eq('business_id', businessId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<ReviewsRow> insertReview(Map<String, dynamic> data) {
    return ReviewsTable().insert(data);
  }

  Future<ComplaintsRow> insertComplaint(Map<String, dynamic> data) {
    return ComplaintsTable().insert(data);
  }

  Future<List<ComplaintsRow>> complaintsForUser(String userId) {
    if (userId.isEmpty) return Future.value(const []);
    return ComplaintsTable().queryRows(
      queryFn: (q) =>
          q.eq('user_id', userId).order('created_at', ascending: false),
    );
  }

  Future<List<BusinessAnalyticsRow>> analyticsFor(String businessId) {
    if (businessId.isEmpty) return Future.value(const []);
    return BusinessAnalyticsTable().queryRows(
      queryFn: (q) => q.eq('business_id', businessId),
    );
  }
}
