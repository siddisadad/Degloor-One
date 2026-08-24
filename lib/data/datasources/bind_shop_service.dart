import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_shop_repository.dart';
import 'package:degloor_one/data/datasources/supabase_shop_repository.dart';
import 'package:degloor_one/data/repositories/shop_repository.dart';

/// Composition-root wiring for shop entities. Domain code takes
/// [ShopRepository] and must not import this file.
///
/// Java owns the table when [JavaApiConfig.enabled]; otherwise showcase or
/// Supabase stays on [SupabaseShopRepository]. Hours, catalogue, and reviews
/// stay on leftover repos until their slices.
void bindShopService({ShopRepository? repository}) {
  final shops = repository ??
      (JavaApiConfig.enabled
          ? JavaShopRepository()
          : SupabaseShopRepository());
  ShopService.bind(shops);
  BusinessService.bind(shops);
}
