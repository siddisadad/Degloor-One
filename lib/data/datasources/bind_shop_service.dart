import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_catalog_repository.dart';
import 'package:degloor_one/data/datasources/java_shop_detail_repository.dart';
import 'package:degloor_one/data/datasources/java_shop_repository.dart';
import 'package:degloor_one/data/datasources/supabase_catalog_repository.dart';
import 'package:degloor_one/data/datasources/supabase_shop_detail_repository.dart';
import 'package:degloor_one/data/datasources/supabase_shop_repository.dart';
import 'package:degloor_one/data/repositories/catalog_repository.dart';
import 'package:degloor_one/data/repositories/shop_detail_repository.dart';
import 'package:degloor_one/data/repositories/shop_repository.dart';

/// Composition-root wiring for shop entities, hours, catalogue, and reviews.
/// Domain code takes the repository interfaces and must not import this file.
///
/// Java owns the tables when [JavaApiConfig.enabled]; otherwise showcase or
/// Supabase stays on the table-backed repositories.
void bindShopService({
  ShopRepository? repository,
  ShopDetailRepository? details,
  CatalogRepository? catalog,
}) {
  final shops = repository ??
      (JavaApiConfig.enabled
          ? JavaShopRepository()
          : SupabaseShopRepository());
  final shopDetails = details ??
      (JavaApiConfig.enabled
          ? JavaShopDetailRepository()
          : SupabaseShopDetailRepository());
  final catalogs = catalog ??
      (JavaApiConfig.enabled
          ? JavaCatalogRepository()
          : SupabaseCatalogRepository());
  ShopService.bind(shops, details: shopDetails);
  BusinessService.bind(shops, catalog: catalogs);
}
