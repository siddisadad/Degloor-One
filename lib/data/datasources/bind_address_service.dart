import 'package:degloor_one/backend/address_service.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_address_repository.dart';
import 'package:degloor_one/data/datasources/supabase_address_repository.dart';
import 'package:degloor_one/data/repositories/address_repository.dart';

/// Composition-root wiring for addresses. Domain code takes [AddressRepository]
/// and must not import this file.
///
/// Java owns the table when [JavaApiConfig.enabled]; otherwise showcase or
/// Supabase stays on [SupabaseAddressRepository].
void bindAddressService({AddressRepository? repository}) {
  AddressService.bind(
    repository ??
        (JavaApiConfig.enabled
            ? JavaAddressRepository()
            : SupabaseAddressRepository()),
  );
}
