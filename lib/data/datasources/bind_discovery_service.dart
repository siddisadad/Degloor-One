import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_discovery_repository.dart';
import 'package:degloor_one/data/datasources/supabase_discovery_repository.dart';
import 'package:degloor_one/data/repositories/discovery_repository.dart';

/// Composition-root wiring for discovery search. Domain code takes
/// [DiscoveryRepository] and must not import this file.
void bindDiscoveryService({DiscoveryRepository? repository}) {
  final discovery = repository ??
      (JavaApiConfig.enabled
          ? JavaDiscoveryRepository()
          : SupabaseDiscoveryRepository());
  DiscoveryService.bind(discovery);
}
