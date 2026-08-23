import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/listing_complaint_draft.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/shop_review_draft.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

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

  Future<List<ShopReview>> reviewsWithUsers(String businessId) async {
    if (businessId.isEmpty) return const [];
    if (kUseShowcaseData) {
      return ShowcaseCatalog.reviewsForBusiness(businessId)
          .map(ShopReview.fromJoin)
          .toList();
    }
    final response = await SupaFlow.client
        .from('reviews')
        .select('*, users(full_name)')
        .eq('business_id', businessId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response)
        .map(ShopReview.fromJoin)
        .toList();
  }

  Future<ShopReview?> reviewByUser({
    required String userId,
    required String businessId,
  }) async {
    if (userId.isEmpty || businessId.isEmpty) return null;
    final rows = await ReviewsTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId).eq('business_id', businessId),
      limit: 1,
    );
    return rows.isEmpty
        ? null
        : ShopReview.fromJoin(Map<String, dynamic>.from(rows.first.data));
  }

  Future<ShopReview> insertReview(ShopReviewDraft draft) async {
    final row = await ReviewsTable().insert(draft.toInsertJson());
    return ShopReview.fromJoin(Map<String, dynamic>.from(row.data));
  }

  Future<ListingComplaint> insertComplaint(ListingComplaintDraft draft) async {
    final row = await ComplaintsTable().insert(draft.toInsertJson());
    return ListingComplaint.fromRow(row);
  }

  Future<List<ListingComplaint>> complaintsForUser(String userId) async {
    if (userId.isEmpty) return const [];
    final rows = await ComplaintsTable().queryRows(
      queryFn: (q) =>
          q.eq('user_id', userId).order('created_at', ascending: false),
    );
    return rows.map(ListingComplaint.fromRow).toList();
  }

  Future<List<BusinessAnalyticsRow>> analyticsFor(String businessId) {
    if (businessId.isEmpty) return Future.value(const []);
    return BusinessAnalyticsTable().queryRows(
      queryFn: (q) => q.eq('business_id', businessId),
    );
  }
}
