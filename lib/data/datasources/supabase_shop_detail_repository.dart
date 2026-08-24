import 'package:degloor_one/backend/repositories/shop_detail_repository.dart'
    as tables;
import 'package:degloor_one/data/datasources/supabase_shop_maps.dart';
import 'package:degloor_one/data/repositories/shop_detail_repository.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/listing_complaint_draft.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'package:degloor_one/shared/shop_event.dart';
import 'package:degloor_one/shared/shop_event_draft.dart';
import 'package:degloor_one/shared/shop_hours.dart';
import 'package:degloor_one/shared/shop_review_draft.dart';

/// Showcase or live table access for shop hours, catalogue, and reports.
class SupabaseShopDetailRepository implements ShopDetailRepository {
  SupabaseShopDetailRepository({tables.ShopDetailRepository? inner})
      : _inner = inner ?? tables.ShopDetailRepository();

  final tables.ShopDetailRepository _inner;

  @override
  Future<ShopCategory?> categoryById(String categoryId) async {
    final row = await _inner.categoryById(categoryId);
    return row == null ? null : shopCategoryFromRow(row);
  }

  @override
  Future<List<ShopHours>> hoursFor(String businessId) async {
    final rows = await _inner.hoursFor(businessId);
    return rows.map(shopHoursFromRow).toList();
  }

  @override
  Future<Map<String, List<ShopHours>>> hoursForMany(
    List<String> businessIds,
  ) async {
    final rows = await _inner.hoursForMany(businessIds);
    return {
      for (final entry in rows.entries)
        entry.key: entry.value.map(shopHoursFromRow).toList(),
    };
  }

  @override
  Future<List<CatalogProduct>> availableProducts(String businessId) async {
    final rows = await _inner.availableProducts(businessId);
    return rows.map(catalogProductFromRow).toList();
  }

  @override
  Future<CatalogProduct?> productById(String productId) async {
    final row = await _inner.productById(productId);
    return row == null ? null : catalogProductFromRow(row);
  }

  @override
  Future<List<ProductCategory>> productCategories(String businessId) async {
    final rows = await _inner.productCategories(businessId);
    return rows.map(productCategoryFromRow).toList();
  }

  @override
  Future<ShopEvent> insertAnalytics(ShopEventDraft draft) {
    return _inner.insertAnalytics(draft);
  }

  @override
  Future<List<ShopReview>> reviewsWithUsers(String businessId) {
    return _inner.reviewsWithUsers(businessId);
  }

  @override
  Future<ShopReview?> reviewByUser({
    required String userId,
    required String businessId,
  }) {
    return _inner.reviewByUser(userId: userId, businessId: businessId);
  }

  @override
  Future<ShopReview> insertReview(ShopReviewDraft draft) {
    return _inner.insertReview(draft);
  }

  @override
  Future<ListingComplaint> insertComplaint(ListingComplaintDraft draft) {
    return _inner.insertComplaint(draft);
  }

  @override
  Future<List<ListingComplaint>> complaintsForUser(String userId) {
    return _inner.complaintsForUser(userId);
  }

  @override
  Future<List<ShopEvent>> analyticsFor(String businessId) async {
    final rows = await _inner.analyticsFor(businessId);
    return rows.map(shopEventFromRow).toList();
  }
}
