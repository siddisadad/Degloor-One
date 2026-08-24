import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_shop_repository.dart';
import 'package:degloor_one/data/repositories/discovery_repository.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'package:degloor_one/shared/shop_event.dart';

/// Discovery through the Java API. Table rows stay on the server.
class JavaDiscoveryRepository implements DiscoveryRepository {
  JavaDiscoveryRepository({JavaApiClient? client})
      : _client = client ?? JavaApiClient.instance;

  final JavaApiClient _client;

  Future<List<Map<String, dynamic>>> _businessRows({
    String? q,
    String? categoryId,
    double? lat,
    double? lng,
    double? radiusKm,
    bool? verified,
  }) async {
    final data = await _client.get('/api/v1/businesses', query: {
      if (q != null && q.isNotEmpty) 'q': q,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (lat != null) 'lat': '$lat',
      if (lng != null) 'lng': '$lng',
      if (radiusKm != null) 'radiusKm': '$radiusKm',
      if (verified != null) 'verified': '$verified',
    });
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  @override
  Future<List<Shop>> search(DiscoverySearch query) async {
    final rows = await _businessRows(
      q: query.searchTerm,
      categoryId: query.categoryId,
      lat: query.latitude,
      lng: query.longitude,
      radiusKm: query.radiusKm,
      verified: query.verifiedOnly ? true : null,
    );
    final shops = <Shop>[];
    for (final row in rows) {
      final shop = JavaShopRepository.fromJson(row);
      if (query.minRating > 0 && (shop.rating ?? 0) < query.minRating) {
        continue;
      }
      if (query.openNow) {
        final hours = JavaShopRepository.hoursFromJson(row);
        final open = hours.isEmpty
            ? shop.isOpen == true
            : ShopService.isOpenFromHours(hours);
        if (!open) continue;
      }
      shops.add(shop);
    }
    return shops.skip(query.page.offset).take(query.page.limit).toList();
  }

  @override
  Future<List<CatalogProduct>> searchProducts(DiscoverySearch query) async {
    final page = query.page.limit <= 0
        ? 0
        : query.page.offset ~/ query.page.limit;
    final data = await _client.get('/api/v1/products', query: {
      'page': '$page',
      'size': '${query.page.limit}',
      if (query.searchTerm != null && query.searchTerm!.isNotEmpty)
        'q': query.searchTerm!,
    });
    final items = data is Map ? data['items'] : data;
    final rows = items is List ? items : const [];
    return rows
        .whereType<Map>()
        .map((row) => CatalogProduct.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<List<ShopCategory>> categories() async {
    final data = await _client.get('/api/v1/categories');
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => ShopCategory.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<List<Shop>> businessesByIds(List<String> ids) async {
    final unique = ids.where((id) => id.isNotEmpty).toSet();
    if (unique.isEmpty) return const [];
    final shops = <Shop>[];
    for (final id in unique) {
      try {
        final data = await _client.get('/api/v1/businesses/$id');
        shops.add(
          JavaShopRepository.fromJson(Map<String, dynamic>.from(data as Map)),
        );
      } on JavaApiException catch (error) {
        if (error.code == 'BUSINESS_NOT_FOUND' || error.code.contains('404')) {
          continue;
        }
        rethrow;
      }
    }
    return shops;
  }

  @override
  Future<List<Shop>> ownedBy(String userId) async {
    if (userId.isEmpty) return const [];
    final data = await _client.get('/api/v1/businesses/mine');
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => JavaShopRepository.fromJson(Map<String, dynamic>.from(row)))
        .where((shop) => shop.ownerId == userId)
        .toList();
  }

  @override
  Future<int> reviewCount(String businessId) async {
    if (businessId.isEmpty) return 0;
    final data = await _client.get('/api/v1/businesses/$businessId/reviews');
    final rows = data is List ? data : const [];
    return rows.length;
  }

  @override
  Future<List<ShopEvent>> analyticsFor(String businessId) async {
    if (businessId.isEmpty) return const [];
    try {
      final data = await _client.get('/api/v1/businesses/$businessId/insights');
      if (data is! Map) return const [];
      return _eventsFromInsights(businessId, Map<String, dynamic>.from(data));
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
