import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_delivery_repository.dart';
import 'package:degloor_one/data/datasources/supabase_delivery_repository.dart';
import 'package:degloor_one/data/repositories/delivery_repository.dart';

/// Composition-root wiring for delivery. Domain code takes [DeliveryRepository]
/// and must not import this file.
///
/// Java owns the tables when [JavaApiConfig.enabled]; otherwise showcase or
/// Supabase stays on [SupabaseDeliveryRepository].
void bindDeliveryService({DeliveryRepository? repository}) {
  DeliveryService.bind(
    repository ??
        (JavaApiConfig.enabled
            ? JavaDeliveryRepository()
            : SupabaseDeliveryRepository()),
  );
}
