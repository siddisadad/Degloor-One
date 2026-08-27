import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/data/repositories/address_repository.dart';
import 'package:degloor_one/shared/address_default_flag.dart';
import 'package:degloor_one/shared/address_draft.dart';
import 'package:degloor_one/shared/saved_address.dart';

/// Showcase or live table access for saved addresses.
class SupabaseAddressRepository implements AddressRepository {
  SavedAddress _toAddress(AddressesRow row) {
    return SavedAddress(
      id: row.id,
      userId: row.userId,
      title: row.title,
      addressText: row.addressText,
      latitude: row.latitude,
      longitude: row.longitude,
      isDefault: row.isDefault,
      createdAt: row.createdAt,
    );
  }

  @override
  Future<List<SavedAddress>> forUser(String userId) async {
    if (userId.isEmpty) return const [];
    final rows = await AddressesTable().queryRows(
      queryFn: (q) =>
          q.eq('user_id', userId).order('created_at', ascending: false),
    );
    return rows.map(_toAddress).toList();
  }

  @override
  Future<SavedAddress?> forUserAndId({
    required String userId,
    required String id,
  }) async {
    if (userId.isEmpty || id.isEmpty) return null;
    final rows = await AddressesTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId).eq('id', id),
      limit: 1,
    );
    return rows.isEmpty ? null : _toAddress(rows.first);
  }

  @override
  Future<SavedAddress> insert(
    AddressDraft draft, {
    AddressDefaultFlag? defaultFlag,
  }) async {
    final row = await AddressesTable().insert(
      draft.toInsertJson(defaultFlag: defaultFlag),
    );
    return _toAddress(row);
  }

  @override
  Future<void> clearDefaults(String userId) async {
    if (userId.isEmpty) return;
    await AddressesTable().update(
      data: const AddressDefaultFlag(false).toUpdateJson(),
      matchingRows: (q) => q.eq('user_id', userId),
    );
  }

  @override
  Future<void> clearDefaultsExcept({
    required String userId,
    required String exceptId,
  }) async {
    if (userId.isEmpty || exceptId.isEmpty) return;
    await AddressesTable().update(
      data: const AddressDefaultFlag(false).toUpdateJson(),
      matchingRows: (q) => q.eq('user_id', userId).neq('id', exceptId),
    );
  }

  @override
  Future<void> setDefault({
    required String id,
    required String userId,
  }) async {
    if (id.isEmpty || userId.isEmpty) return;
    await AddressesTable().update(
      data: const AddressDefaultFlag(true).toUpdateJson(),
      matchingRows: (q) => q.eq('id', id).eq('user_id', userId),
    );
  }

  @override
  Future<void> delete({
    required String id,
    required String userId,
  }) async {
    if (id.isEmpty || userId.isEmpty) return;
    await AddressesTable().delete(
      matchingRows: (q) => q.eq('id', id).eq('user_id', userId),
    );
  }

  @override
  Future<double> deliveryFee({
    required String businessId,
    required String addressId,
  }) async {
    if (kUseShowcaseData) return 25;
    try {
      final response = await SupaFlow.client.rpc(
        'calculate_delivery_fee',
        params: {
          'business_id': businessId,
          'address_id': addressId,
        },
      );
      return (response as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      AppLogger.error('Error calculating delivery fee', e);
      return 0.0;
    }
  }
}
