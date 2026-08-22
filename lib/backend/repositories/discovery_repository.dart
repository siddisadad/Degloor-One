import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';

class DiscoverySearch {
  const DiscoverySearch({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    this.searchTerm,
    this.categoryId,
    this.openNow = false,
    this.verifiedOnly = false,
    this.minRating = 0.0,
    this.page = const PageQuery(),
  });

  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? searchTerm;
  final String? categoryId;
  final bool openNow;
  final bool verifiedOnly;
  final double minRating;
  final PageQuery page;
}

/// Radius search and catalogue lookups. Widgets should go through
/// [DiscoveryService].
class DiscoveryRepository {
  Future<List<BusinessesRow>> search(DiscoverySearch query) {
    return BusinessesTable().searchInRadius(
      latitude: query.latitude,
      longitude: query.longitude,
      radiusKm: query.radiusKm,
      searchTerm: query.searchTerm,
      categoryId: query.categoryId,
      openNow: query.openNow,
      verifiedOnly: query.verifiedOnly,
      minRating: query.minRating,
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
}
