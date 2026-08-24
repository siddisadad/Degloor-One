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

/// Public shop hours, catalogue, reviews, reports, and analytics.
/// Widgets go through [ShopService].
abstract class ShopDetailRepository {
  Future<ShopCategory?> categoryById(String categoryId);

  Future<List<ShopHours>> hoursFor(String businessId);

  Future<Map<String, List<ShopHours>>> hoursForMany(List<String> businessIds);

  Future<List<CatalogProduct>> availableProducts(String businessId);

  Future<CatalogProduct?> productById(String productId);

  Future<List<ProductCategory>> productCategories(String businessId);

  Future<ShopEvent> insertAnalytics(ShopEventDraft draft);

  Future<List<ShopReview>> reviewsWithUsers(String businessId);

  Future<ShopReview?> reviewByUser({
    required String userId,
    required String businessId,
  });

  Future<ShopReview> insertReview(ShopReviewDraft draft);

  Future<ListingComplaint> insertComplaint(ListingComplaintDraft draft);

  Future<List<ListingComplaint>> complaintsForUser(String userId);

  Future<List<ShopEvent>> analyticsFor(String businessId);
}
