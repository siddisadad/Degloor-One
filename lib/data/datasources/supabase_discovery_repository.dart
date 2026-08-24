import 'package:degloor_one/backend/repositories/discovery_repository.dart'
    as tables;
import 'package:degloor_one/data/repositories/discovery_repository.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'package:degloor_one/shared/shop_event.dart';

/// Showcase or live table access for discovery search.
class SupabaseDiscoveryRepository implements DiscoveryRepository {
  SupabaseDiscoveryRepository({tables.DiscoveryRepository? inner})
      : _inner = inner ?? tables.DiscoveryRepository();

  final tables.DiscoveryRepository _inner;

  @override
  Future<List<Shop>> search(DiscoverySearch query) {
    return _inner.search(query);
  }

  @override
  Future<List<CatalogProduct>> searchProducts(DiscoverySearch query) async {
    final rows = await _inner.searchProducts(query);
    return rows.map(CatalogProduct.fromRow).toList();
  }

  @override
  Future<List<ShopCategory>> categories() async {
    final rows = await _inner.categories();
    return rows.map(ShopCategory.fromRow).toList();
  }

  @override
  Future<List<Shop>> businessesByIds(List<String> ids) {
    return _inner.businessesByIds(ids);
  }

  @override
  Future<List<Shop>> ownedBy(String userId) {
    return _inner.ownedBy(userId);
  }

  @override
  Future<int> reviewCount(String businessId) {
    return _inner.reviewCount(businessId);
  }

  @override
  Future<List<ShopEvent>> analyticsFor(String businessId) async {
    final rows = await _inner.analyticsFor(businessId);
    return rows.map(ShopEvent.fromRow).toList();
  }
}
