import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_cart_repository.dart';
import 'package:degloor_one/data/datasources/supabase_cart_repository.dart';
import 'package:degloor_one/data/repositories/cart_repository.dart';

/// Composition-root wiring for the cart. Domain code takes [CartRepository]
/// and must not import this file.
///
/// Java owns the tables when [JavaApiConfig.enabled]; otherwise showcase or
/// Supabase stays on [SupabaseCartRepository].
void bindCartService({CartRepository? repository}) {
  CartService.bind(
    repository ??
        (JavaApiConfig.enabled
            ? JavaCartRepository()
            : SupabaseCartRepository()),
  );
}
