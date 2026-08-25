import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/data/datasources/supabase_shop_maps.dart';
import 'package:degloor_one/data/repositories/discovery_repository.dart'
    show DiscoverySearch;
import 'package:degloor_one/shared/shop.dart';

export 'package:degloor_one/data/repositories/discovery_repository.dart'
    show DiscoverySearch;

/// Radius search and catalogue lookups. Widgets should go through
/// [DiscoveryService]. Table-backed implementation; Java lives under
/// `lib/data/datasources`.
class DiscoveryRepository {
  Shop _toShop(BusinessesRow row) => shopFromRow(row);

  Future<List<Shop>> search(DiscoverySearch query) async {
    final rows = await BusinessesTable().searchInRadius(
      latitude: query.latitude,
      longitude: query.longitude,
      radiusKm: query.radiusKm,
      searchTerm: query.searchTerm,
      categoryId: query.categoryId,
      subcategory: query.subcategory,
      openNow: query.openNow,
      verifiedOnly: query.verifiedOnly,
      minRating: query.minRating,
      limit: query.page.limit,
      offset: query.page.offset,
    );
    return rows.map(_toShop).toList();
  }

  Future<List<ProductsRow>> searchProducts(DiscoverySearch query) {
    return ProductsTable().searchInRadius(
      latitude: query.latitude,
      longitude: query.longitude,
      radiusKm: query.radiusKm,
      searchTerm: query.searchTerm,
      limit: query.page.limit,
      offset: query.page.offset,
    );
  }

  Future<List<BusinessCategoriesRow>> categories() {
    return BusinessCategoriesTable().queryRows(
      queryFn: (q) => q.order('display_order', ascending: true),
    );
  }

  Future<List<UsersRow>> usersByIds(List<String> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return UsersTable().queryRows(
      queryFn: (q) => q.inFilter('id', ids),
    );
  }

  Future<List<Shop>> businessesByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await BusinessesTable().queryRows(
      queryFn: (q) => q.inFilter('id', ids),
    );
    return rows.map(_toShop).toList();
  }

  Future<List<Shop>> ownedBy(String userId) async {
    if (userId.isEmpty) return const [];
    final rows = await BusinessesTable().queryRows(
      queryFn: (q) => q.eq('owner_id', userId),
    );
    return rows.map(_toShop).toList();
  }

  Future<int> reviewCount(String businessId) async {
    if (businessId.isEmpty) return 0;
    final rows = await ReviewsTable().queryRows(
      queryFn: (q) => q.eq('business_id', businessId),
    );
    return rows.length;
  }

  Future<List<BusinessAnalyticsRow>> analyticsFor(String businessId) {
    if (businessId.isEmpty) return Future.value(const []);
    return BusinessAnalyticsTable().queryRows(
      queryFn: (q) => q.eq('business_id', businessId),
    );
  }
}
