import 'package:degloor_one/shared/address_default_flag.dart';
import 'package:degloor_one/shared/address_draft.dart';
import 'package:degloor_one/shared/saved_address.dart';

/// Data access for saved customer addresses. Widgets should go through
/// [AddressService]. Implementations live under `data/datasources`.
abstract class AddressRepository {
  Future<List<SavedAddress>> forUser(String userId);

  Future<SavedAddress?> forUserAndId({
    required String userId,
    required String id,
  });

  Future<SavedAddress> insert(
    AddressDraft draft, {
    AddressDefaultFlag? defaultFlag,
  });

  Future<void> clearDefaults(String userId);

  Future<void> clearDefaultsExcept({
    required String userId,
    required String exceptId,
  });

  Future<void> setDefault({
    required String id,
    required String userId,
  });

  Future<void> delete({
    required String id,
    required String userId,
  });

  Future<double> deliveryFee({
    required String businessId,
    required String addressId,
  });
}
