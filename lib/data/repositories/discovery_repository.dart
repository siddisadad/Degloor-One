import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'package:degloor_one/shared/shop_event.dart';

class DiscoverySearch {
  const DiscoverySearch({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    this.searchTerm,
    this.categoryId,
    this.subcategory,
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
  final String? subcategory;
  final bool openNow;
  final bool verifiedOnly;
  final double minRating;
  final PageQuery page;
}

/// Radius search and catalogue lookups. Widgets go through [DiscoveryService].
abstract class DiscoveryRepository {
  Future<List<Shop>> search(DiscoverySearch query);

  Future<List<CatalogProduct>> searchProducts(DiscoverySearch query);

  Future<List<ShopCategory>> categories();

  Future<List<Shop>> businessesByIds(List<String> ids);

  Future<List<Shop>> ownedBy(String userId);

  Future<int> reviewCount(String businessId);

  Future<List<ShopEvent>> analyticsFor(String businessId);
}
