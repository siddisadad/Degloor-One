import 'package:degloor_one/backend/native_service_bridge.dart';
import 'package:degloor_one/backend/repositories/discovery_repository.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/user_profile.dart';

export 'package:degloor_one/backend/repositories/discovery_repository.dart'
    show DiscoverySearch;

class DiscoveryService {
  DiscoveryService({DiscoveryRepository? repository})
      : _repository = repository ?? DiscoveryRepository();

  final DiscoveryRepository _repository;

  static final instance = DiscoveryService();

  Future<PageResult<Shop>> search(DiscoverySearch query) async {
    final rows = await _repository.search(query);
    return PageResult(
      items: rows.map(Shop.fromRow).toList(),
      hasMore: rows.length >= query.page.limit,
    );
  }

  Future<PageResult<ProductsRow>> searchProducts(DiscoverySearch query) async {
    final rows = await _repository.searchProducts(query);
    return PageResult(items: rows, hasMore: rows.length >= query.page.limit);
  }

  Future<List<BusinessCategoriesRow>> categories() async {
    final native = await NativeServiceBridge.getDiscoveryCategories();
    if (native.isNotEmpty) return native;
    return _repository.categories();
  }

  Future<List<UserProfile>> profile(String userId) =>
      UserService.instance.profile(userId);

  Future<List<UserProfile>> usersByIds(List<String> ids) =>
      UserService.instance.byIds(ids);

  Future<List<Shop>> businessesByIds(List<String> ids) async {
    final rows = await _repository.businessesByIds(ids);
    return rows.map(Shop.fromRow).toList();
  }

  Future<List<Shop>> ownedBy(String userId) async {
    final rows = await _repository.ownedBy(userId);
    return rows.map(Shop.fromRow).toList();
  }

  Future<ShopInsights> insightsFor(String businessId) async {
    if (businessId.isEmpty) return ShopInsights.empty;
    final reviews = await _repository.reviewCount(businessId);
    final events = await _repository.analyticsFor(businessId);
    final summary = ShopService.summarizeEvents(events);
    return ShopInsights(
      reviewCount: reviews,
      profileViews: summary.profileViews,
      callClicks: summary.callClicks,
      whatsappClicks: summary.whatsappClicks,
      directionsClicks: summary.directionsClicks,
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
