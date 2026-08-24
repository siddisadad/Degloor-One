import 'package:degloor_one/backend/address_service.dart';
import 'package:degloor_one/data/datasources/supabase_address_repository.dart';
import 'package:degloor_one/data/repositories/address_repository.dart';

/// Composition-root wiring for addresses. Domain code takes [AddressRepository]
/// and must not import this file.
void bindAddressService({AddressRepository? repository}) {
  AddressService.bind(repository ?? SupabaseAddressRepository());
}
