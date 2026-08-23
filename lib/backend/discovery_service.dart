import 'package:degloor_one/backend/repositories/discovery_repository.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';

export 'package:degloor_one/backend/repositories/discovery_repository.dart'
    show DiscoverySearch;

class DiscoveryService {
  DiscoveryService({DiscoveryRepository? repository})
      : _repository = repository ?? DiscoveryRepository();

  final DiscoveryRepository _repository;

  static final instance = DiscoveryService();

  Future<PageResult<BusinessesRow>> search(DiscoverySearch query) async {
    final rows = await _repository.search(query);
    return PageResult(items: rows, hasMore: rows.length >= query.page.limit);
  }

  Future<PageResult<ProductsRow>> searchProducts(DiscoverySearch query) async {
    final rows = await _repository.searchProducts(query);
    return PageResult(items: rows, hasMore: rows.length >= query.page.limit);
  }

  Future<List<BusinessCategoriesRow>> categories() => _repository.categories();

  Future<List<UsersRow>> profile(String userId) {
    if (userId.isEmpty) return Future.value(const []);
    return _repository.usersByIds([userId]);
  }

  Future<List<UsersRow>> usersByIds(List<String> ids) =>
      _repository.usersByIds(ids);

  Future<List<BusinessesRow>> businessesByIds(List<String> ids) =>
      _repository.businessesByIds(ids);

  Future<List<BusinessesRow>> ownedBy(String userId) =>
      _repository.ownedBy(userId);

  Future<ShopInsights> insightsFor(String businessId) async {
    if (businessId.isEmpty) return ShopInsights.empty;
    final reviews = await _repository.reviewCount(businessId);
    final events = await _repository.analyticsFor(businessId);
    var views = 0;
    var calls = 0;
    var whatsapp = 0;
    var directions = 0;
    for (final event in events) {
      final type = event.eventType;
      if (type == 'PROFILE_VIEW') views++;
      if (type == 'CALL_CLICK') calls++;
      if (type == 'WHATSAPP_CLICK') whatsapp++;
      if (type == 'DIRECTIONS_CLICK') directions++;
    }
    return ShopInsights(
      reviewCount: reviews,
      profileViews: views,
      callClicks: calls,
      whatsappClicks: whatsapp,
      directionsClicks: directions,
    );
  }
}

class ShopInsights {
  const ShopInsights({
    required this.reviewCount,
    required this.profileViews,
    required this.callClicks,
    required this.whatsappClicks,
    required this.directionsClicks,
  });

  static const empty = ShopInsights(
    reviewCount: 0,
    profileViews: 0,
    callClicks: 0,
    whatsappClicks: 0,
    directionsClicks: 0,
  );

  final int reviewCount;
  final int profileViews;
  final int callClicks;
  final int whatsappClicks;
  final int directionsClicks;
}
