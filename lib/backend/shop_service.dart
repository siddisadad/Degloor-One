import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/data/repositories/shop_detail_repository.dart';
import 'package:degloor_one/data/repositories/shop_repository.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/listing_complaint_draft.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_event.dart';
import 'package:degloor_one/shared/shop_event_draft.dart';
import 'package:degloor_one/shared/shop_hours.dart';
import 'package:degloor_one/shared/shop_review_draft.dart';

class ShopEvents {
  static const profileView = 'PROFILE_VIEW';
  static const callClick = 'CALL_CLICK';
  static const whatsappClick = 'WHATSAPP_CLICK';
  static const directionsClick = 'DIRECTIONS_CLICK';
  static const shareClick = 'SHARE_CLICK';
  static const reviewSubmitted = 'REVIEW_SUBMITTED';
  static const productView = 'PRODUCT_VIEW';
}

class ShopEventSummary {
  const ShopEventSummary({
    required this.profileViews,
    required this.callClicks,
    required this.whatsappClicks,
    required this.directionsClicks,
    required this.dailyCounts,
  });

  static const empty = ShopEventSummary(
    profileViews: 0,
    callClicks: 0,
    whatsappClicks: 0,
    directionsClicks: 0,
    dailyCounts: {},
  );

  final int profileViews;
  final int callClicks;
  final int whatsappClicks;
  final int directionsClicks;
  final Map<String, int> dailyCounts;

  int get inquiries => callClicks + whatsappClicks;

  double get conversionRate =>
      profileViews > 0 ? inquiries / profileViews * 100 : 0;

  int get peakDaily =>
      dailyCounts.values.fold(0, (max, count) => count > max ? count : max);
}

class ShopCatalog {
  const ShopCatalog({
    required this.products,
    required this.categories,
    required this.grouped,
  });

  static const empty = ShopCatalog(
    products: [],
    categories: [],
    grouped: {},
  );

  final List<CatalogProduct> products;
  final List<ProductCategory> categories;
  final Map<String, List<CatalogProduct>> grouped;
}

class ShopReviews {
  const ShopReviews({
    required this.items,
    required this.distribution,
  });

  static const empty = ShopReviews(
    items: [],
    distribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
  );

  final List<ShopReview> items;
  final Map<int, int> distribution;
}

class ShopService {
  ShopService({
    required ShopRepository shops,
    required ShopDetailRepository details,
  })  : _shops = shops,
        _details = details;

  final ShopRepository _shops;
  final ShopDetailRepository _details;

  static ShopService? _instance;

  static ShopService get instance {
    final bound = _instance;
    if (bound == null) {
      throw StateError('ShopService is not bound.');
    }
    return bound;
  }

  /// Called from the composition root with concrete repositories.
  static void bind(
    ShopRepository shops, {
    required ShopDetailRepository details,
  }) {
    _instance = ShopService(shops: shops, details: details);
  }

  Future<Shop?> byId(String businessId) async {
    if (businessId.isEmpty) return null;
    return _shops.byId(businessId);
  }

  Future<String?> categoryName(String? categoryId) async {
    if (categoryId == null || categoryId.isEmpty) return null;
    final category = await _details.categoryById(categoryId);
    return category?.name;
  }

  Future<List<ShopHours>> hours(String businessId) {
    return _details.hoursFor(businessId);
  }

  /// Weekday is Sunday=0 (`DateTime.weekday % 7`). Overnight windows
  /// (`close <= open`) wrap midnight. Empty / closed / missing times are closed.
  static bool isOpenFromHours(
    List<ShopHours> hours, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final dayOfWeek = at.weekday % 7;
    final currentMinutes = at.hour * 60 + at.minute;
    for (final row in hours) {
      if (row.dayOfWeek != dayOfWeek) continue;
      if (row.isClosed) return false;
      final open = row.openTime;
      final close = row.closeTime;
      if (open == null || close == null) return false;
      final openMinutes = open.hour * 60 + open.minute;
      final closeMinutes = close.hour * 60 + close.minute;
      if (closeMinutes > openMinutes) {
        return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
      }
      return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
    }
    return false;
  }

  Future<bool> isOpenNow(String businessId, {DateTime? now}) async {
    if (businessId.isEmpty) return false;
    try {
      return isOpenFromHours(await hours(businessId), now: now);
    } catch (error) {
      AppLogger.error('Error checking business open status', error);
      return false;
    }
  }

  Future<Map<String, bool>> isOpenNowBatch(
    List<String> businessIds, {
    DateTime? now,
  }) async {
    if (businessIds.isEmpty) return {};
    try {
      final at = now ?? DateTime.now();
      final hoursById = await _details.hoursForMany(businessIds);
      return {
        for (final id in businessIds)
          id: isOpenFromHours(hoursById[id] ?? const [], now: at),
      };
    } catch (error) {
      AppLogger.error('Error checking multiple business open statuses', error);
      return {for (final id in businessIds) id: false};
    }
  }

  Future<ShopCatalog> catalog(String businessId) async {
    if (businessId.isEmpty) return ShopCatalog.empty;
    final products = await _details.availableProducts(businessId);
    final categories = await _details.productCategories(businessId);
    final grouped = <String, List<CatalogProduct>>{};
    for (final product in products) {
      final key = product.categoryId ?? 'Uncategorized';
      grouped.putIfAbsent(key, () => []).add(product);
    }
    return ShopCatalog(
      products: products,
      categories: categories,
      grouped: grouped,
    );
  }

  Future<CatalogProduct?> productById(String productId) async {
    if (productId.isEmpty) return null;
    return _details.productById(productId);
  }

  Future<void> trackEvent({
    required String businessId,
    required String eventType,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    if (businessId.isEmpty || eventType.isEmpty) return;
    final actor = userId ?? currentUserUid;
    try {
      await _details.insertAnalytics(
        ShopEventDraft(
          businessId: businessId,
          eventType: eventType,
          userId: actor.isEmpty ? null : actor,
          metadata: metadata,
        ),
      );
    } catch (error) {
      AppLogger.error('Analytics Error ($eventType)', error);
    }
  }

  Future<ShopReviews> reviews(String businessId) async {
    if (businessId.isEmpty) return ShopReviews.empty;
    final items = await _details.reviewsWithUsers(businessId);
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in items) {
      if (dist.containsKey(review.rating)) {
        dist[review.rating] = dist[review.rating]! + 1;
      }
    }
    return ShopReviews(items: items, distribution: dist);
  }

  Future<void> addReview({
    required String userId,
    required String businessId,
    required int rating,
    String comment = '',
  }) async {
    if (userId.isEmpty) {
      throw Exception('Please sign in to write a review');
    }
    if (businessId.isEmpty) {
      throw Exception('Shop not found');
    }
    if (rating < 1 || rating > 5) {
      throw Exception('Please choose a rating');
    }
    final shop = await _shops.byId(businessId);
    if (shop == null) {
      throw Exception('Shop not found');
    }
    final existing = await _details.reviewByUser(
      userId: userId,
      businessId: businessId,
    );
    if (existing != null) {
      throw Exception('You have already reviewed this shop');
    }
    await _details.insertReview(
      ShopReviewDraft(
        userId: userId,
        businessId: businessId,
        rating: rating,
        comment: comment.trim(),
      ),
    );
    final ownerId = shop.ownerId;
    if (ownerId != null && ownerId.isNotEmpty) {
      await NotificationService.notifyNewReview(
        ownerId: ownerId,
        businessName: shop.name,
        rating: rating,
      );
    }
    await trackEvent(
      businessId: businessId,
      eventType: ShopEvents.reviewSubmitted,
      userId: userId,
    );
  }

  Future<ListingComplaint> reportListing({
    required String userId,
    required String businessId,
    required String subject,
    required String description,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Please sign in to report a listing');
    }
    final trimmedSubject = subject.trim();
    final trimmedDescription = description.trim();
    if (trimmedSubject.isEmpty || trimmedDescription.isEmpty) {
      throw Exception('Please fill all fields');
    }
    final shop = await _shops.byId(businessId);
    if (shop == null) {
      throw Exception('Shop not found');
    }
    return _details.insertComplaint(
      ListingComplaintDraft(
        userId: userId,
        businessId: businessId,
        subject: trimmedSubject,
        description: trimmedDescription,
      ),
    );
  }

  Future<List<ListingComplaint>> complaintsForUser(String userId) {
    if (userId.isEmpty) return Future.value(const []);
    return _details.complaintsForUser(userId);
  }

  Future<List<ShopEvent>> eventsFor({
    required String userId,
    required String businessId,
    int days = 0,
  }) async {
    await BusinessService.instance.requireOwnedBusiness(
      userId: userId,
      businessId: businessId,
    );
    final events = await _details.analyticsFor(businessId);
    if (days <= 0) return events;
    final start = DateTime.now().subtract(Duration(days: days));
    return events
        .where((event) => !event.createdAt.isBefore(start))
        .toList();
  }

  static ShopEventSummary summarizeEvents(List<ShopEvent> events) {
    var profileViews = 0;
    var callClicks = 0;
    var whatsappClicks = 0;
    var directionsClicks = 0;
    final dailyCounts = <String, int>{};
    for (final event in events) {
      switch (event.eventType) {
        case ShopEvents.profileView:
          profileViews++;
        case ShopEvents.callClick:
          callClicks++;
        case ShopEvents.whatsappClick:
          whatsappClicks++;
        case ShopEvents.directionsClick:
          directionsClicks++;
      }
      try {
        final at = event.createdAt;
        final key =
            '${at.month.toString().padLeft(2, '0')}/${at.day.toString().padLeft(2, '0')}';
        dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
      } catch (_) {}
    }
    return ShopEventSummary(
      profileViews: profileViews,
      callClicks: callClicks,
      whatsappClicks: whatsappClicks,
      directionsClicks: directionsClicks,
      dailyCounts: dailyCounts,
    );
  }
}
