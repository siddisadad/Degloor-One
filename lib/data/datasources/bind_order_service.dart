import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_order_repository.dart';
import 'package:degloor_one/data/datasources/supabase_order_repository.dart';
import 'package:degloor_one/data/repositories/order_repository.dart';

/// Composition-root wiring for orders. Domain code takes [OrderRepository]
/// and must not import this file.
///
/// Java owns the tables when [JavaApiConfig.enabled]; otherwise showcase or
/// Supabase stays on [SupabaseOrderRepository].
void bindOrderService({OrderRepository? repository}) {
  OrderService.bind(
    repository ??
        (JavaApiConfig.enabled
            ? JavaOrderRepository()
            : SupabaseOrderRepository()),
  );
}
