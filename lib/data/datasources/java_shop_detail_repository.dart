import 'dart:convert';

import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_shop_repository.dart';
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
import 'package:degloor_one/backend/shop_service.dart';

/// Public shop hours, catalogue, reviews, and reports through the Java API.
class JavaShopDetailRepository implements ShopDetailRepository {
  JavaShopDetailRepository({JavaApiClient? client})
      : _client = client ?? JavaApiClient.instance;

  final JavaApiClient _client;

  Future<Map<String, dynamic>?> _businessJson(String businessId) async {
    if (businessId.isEmpty) return null;
    try {
      final data = await _client.get('/api/v1/businesses/$businessId');
      return Map<String, dynamic>.from(data as Map);
    } on JavaApiException catch (error) {
      if (error.code == 'BUSINESS_NOT_FOUND' || error.code.contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<ShopCategory?> categoryById(String categoryId) async {
    if (categoryId.isEmpty) return null;
    final data = await _client.get('/api/v1/categories');
    final rows = data is List ? data : const [];
    for (final row in rows.whereType<Map>()) {
      final category = ShopCategory.fromJson(Map<String, dynamic>.from(row));
      if (category.id == categoryId) return category;
    }
    return null;
  }

  @override
  Future<List<ShopHours>> hoursFor(String businessId) async {
    final json = await _businessJson(businessId);
    if (json == null) return const [];
    return JavaShopRepository.hoursFromJson(json);
  }

  @override
  Future<Map<String, List<ShopHours>>> hoursForMany(
    List<String> businessIds,
  ) async {
    final ids = businessIds.where((id) => id.isNotEmpty).toSet();
    if (ids.isEmpty) return {};
    final data = await _client.get('/api/v1/businesses');
    final rows = data is List ? data : const [];
    final map = {for (final id in ids) id: <ShopHours>[]};
    for (final row in rows.whereType<Map>()) {
      final json = Map<String, dynamic>.from(row);
      final id = '${json['id'] ?? ''}';
      if (!ids.contains(id)) continue;
      map[id] = JavaShopRepository.hoursFromJson(json);
    }
    return map;
  }

  @override
  Future<List<CatalogProduct>> availableProducts(String businessId) async {
    if (businessId.isEmpty) return const [];
    final data = await _client.get(
      '/api/v1/businesses/$businessId/products',
      query: {'availableOnly': 'true'},
    );
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => CatalogProduct.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<CatalogProduct?> productById(String productId) async {
    if (productId.isEmpty) return null;
    try {
      final data = await _client.get('/api/v1/products/$productId');
      return CatalogProduct.fromJson(Map<String, dynamic>.from(data as Map));
    } on JavaApiException catch (error) {
      if (error.code.contains('404') || error.code.contains('NOT_FOUND')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<ProductCategory>> productCategories(String businessId) async {
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
  Future<ShopEvent> insertAnalytics(ShopEventDraft draft) async {
    await _client.post('/api/v1/analytics/events', {
      'businessId': draft.businessId,
      'eventType': draft.eventType,
      if (draft.metadata != null) 'metadata': jsonEncode(draft.metadata),
    });
    return ShopEvent(
      id: '',
      businessId: draft.businessId,
      eventType: draft.eventType,
      createdAt: DateTime.now(),
      userId: draft.userId,
      metadata: draft.metadata,
    );
  }

  @override
  Future<List<ShopReview>> reviewsWithUsers(String businessId) async {
    if (businessId.isEmpty) return const [];
    final data = await _client.get('/api/v1/businesses/$businessId/reviews');
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => ShopReview.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<ShopReview?> reviewByUser({
    required String userId,
    required String businessId,
  }) async {
    if (userId.isEmpty || businessId.isEmpty) return null;
    final reviews = await reviewsWithUsers(businessId);
    for (final review in reviews) {
      if (review.userId == userId) return review;
    }
    return null;
  }

  @override
  Future<ShopReview> insertReview(ShopReviewDraft draft) async {
    final data = await _client.post('/api/v1/reviews', {
      'businessId': draft.businessId,
      'rating': draft.rating,
      'comment': draft.comment,
      if (draft.orderId != null && draft.orderId!.isNotEmpty)
        'orderId': draft.orderId,
    });
    return ShopReview.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<ListingComplaint> insertComplaint(ListingComplaintDraft draft) async {
    final data = await _client.post('/api/v1/complaints', {
      'businessId': draft.businessId,
      'subject': draft.subject,
      'description': draft.description,
      if (draft.orderId != null && draft.orderId!.isNotEmpty)
        'orderId': draft.orderId,
    });
    return ListingComplaint.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<List<ListingComplaint>> complaintsForUser(String userId) async {
    if (userId.isEmpty) return const [];
    final data = await _client.get('/api/v1/complaints/mine');
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => ListingComplaint.fromJson(Map<String, dynamic>.from(row)))
        .where((row) => row.userId == userId)
        .toList();
  }

  @override
  Future<List<ShopEvent>> analyticsFor(String businessId) async {
    if (businessId.isEmpty) return const [];
    try {
      final data = await _client.get('/api/v1/businesses/$businessId/insights');
      if (data is! Map) return const [];
      return _eventsFromInsights(
        businessId,
        Map<String, dynamic>.from(data),
      );
    } on JavaApiException {
      return const [];
    }
  }
}

List<ShopEvent> _eventsFromInsights(
  String businessId,
  Map<String, dynamic> insights,
) {
  final now = DateTime.now();
  ShopEvent event(String type, int index) {
    return ShopEvent(
      id: '$businessId-$type-$index',
      businessId: businessId,
      eventType: type,
      createdAt: now,
    );
  }

  int count(String key) => (insights[key] as num?)?.toInt() ?? 0;
  return [
    for (var i = 0; i < count('profileViews'); i++)
      event(ShopEvents.profileView, i),
    for (var i = 0; i < count('calls'); i++) event(ShopEvents.callClick, i),
    for (var i = 0; i < count('whatsapp'); i++)
      event(ShopEvents.whatsappClick, i),
    for (var i = 0; i < count('reviews'); i++)
      event(ShopEvents.reviewSubmitted, i),
  ];
}
