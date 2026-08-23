import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/backend/repositories/shop_repository.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';

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

  final List<ProductsRow> products;
  final List<ProductCategoriesRow> categories;
  final Map<String, List<ProductsRow>> grouped;
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
  ShopService({ShopRepository? repository})
      : _repository = repository ?? ShopRepository();

  final ShopRepository _repository;

  static final instance = ShopService();

  Future<BusinessesRow?> byId(String businessId) {
    if (businessId.isEmpty) return Future<BusinessesRow?>.value();
    return _repository.byId(businessId);
  }

  Future<String?> categoryName(String? categoryId) async {
    if (categoryId == null || categoryId.isEmpty) return null;
    final row = await _repository.categoryById(categoryId);
    return row?.name;
  }

  Future<List<BusinessHoursRow>> hours(String businessId) {
    return _repository.hoursFor(businessId);
  }

  /// Weekday is Sunday=0 (`DateTime.weekday % 7`). Overnight windows
  /// (`close <= open`) wrap midnight. Empty / closed / missing times are closed.
  static bool isOpenFromHours(
    List<BusinessHoursRow> hours, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final dayOfWeek = at.weekday % 7;
    final currentMinutes = at.hour * 60 + at.minute;
    for (final row in hours) {
      if (row.dayOfWeek != dayOfWeek) continue;
      if (row.isClosed) return false;
      final open = row.openTime?.time;
      final close = row.closeTime?.time;
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
      final hoursById = await _repository.hoursForMany(businessIds);
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
    final products = await _repository.availableProducts(businessId);
    final categories = await _repository.productCategories(businessId);
    final grouped = <String, List<ProductsRow>>{};
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

  Future<ProductsRow?> productById(String productId) {
    if (productId.isEmpty) return Future<ProductsRow?>.value();
    return _repository.productById(productId);
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
      await _repository.insertAnalytics({
        'business_id': businessId,
        'event_type': eventType,
        if (actor.isNotEmpty) 'user_id': actor,
        if (metadata != null) 'metadata': metadata,
      });
    } catch (error) {
      AppLogger.error('Analytics Error ($eventType)', error);
    }
  }

  Future<ShopReviews> reviews(String businessId) async {
    if (businessId.isEmpty) return ShopReviews.empty;
    final items = await _repository.reviewsWithUsers(businessId);
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
    final shop = await _repository.byId(businessId);
    if (shop == null) {
      throw Exception('Shop not found');
    }
    final existing = await _repository.reviewByUser(
      userId: userId,
      businessId: businessId,
    );
    if (existing != null) {
      throw Exception('You have already reviewed this shop');
    }
    await _repository.insertReview({
      'user_id': userId,
      'business_id': businessId,
      'rating': rating,
      'comment': comment.trim(),
    });
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

  Future<ComplaintsRow> reportListing({
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
    final shop = await _repository.byId(businessId);
    if (shop == null) {
      throw Exception('Shop not found');
    }
    return _repository.insertComplaint({
      'user_id': userId,
      'business_id': businessId,
      'subject': trimmedSubject,
      'description': trimmedDescription,
      'status': 'pending',
    });
  }

  Future<List<ComplaintsRow>> complaintsForUser(String userId) {
    if (userId.isEmpty) return Future.value(const []);
    return _repository.complaintsForUser(userId);
  }

  Future<List<BusinessAnalyticsRow>> eventsFor({
    required String userId,
    required String businessId,
    int days = 0,
  }) async {
    await BusinessService.instance.requireOwnedBusiness(
      userId: userId,
      businessId: businessId,
    );
    final rows = await _repository.analyticsFor(businessId);
    if (days <= 0) return rows;
    final start = DateTime.now().subtract(Duration(days: days));
    return rows.where((row) {
      try {
        return !row.createdAt.isBefore(start);
      } catch (_) {
        return true;
      }
    }).toList();
  }

  static ShopEventSummary summarizeEvents(List<BusinessAnalyticsRow> events) {
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
