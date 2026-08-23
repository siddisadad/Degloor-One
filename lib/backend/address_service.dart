import 'package:degloor_one/backend/repositories/address_repository.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/address_default_flag.dart';
import 'package:degloor_one/shared/address_draft.dart';
import 'package:degloor_one/shared/saved_address.dart';

class AddressService {
  AddressService({AddressRepository? repository})
      : _repository = repository ?? AddressRepository();

  final AddressRepository _repository;

  static final instance = AddressService();

  static const _signInMessage = 'Please sign in to manage addresses';
  static const _missingMessage = 'Address not found';

  Future<List<SavedAddress>> listForUser(String userId) async {
    if (userId.isEmpty) return const [];
    final rows = await _repository.forUser(userId);
    return rows.map(SavedAddress.fromRow).toList();
  }

  /// Default first; otherwise the newest saved row.
  static SavedAddress? pickDefault(List<SavedAddress> rows) {
    if (rows.isEmpty) return null;
    for (final row in rows) {
      if (row.isDefault) return row;
    }
    return rows.first;
  }

  Future<SavedAddress?> defaultFor(String userId) async {
    return pickDefault(await listForUser(userId));
  }

  Future<SavedAddress> requireForUser({
    required String userId,
    required String id,
  }) async {
    if (userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    final row = await _repository.forUserAndId(userId: userId, id: id);
    if (row == null) {
      throw Exception(_missingMessage);
    }
    return SavedAddress.fromRow(row);
  }

  Future<SavedAddress> add(AddressDraft draft) async {
    if (draft.userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    final normalized = AddressDraft.fromForm(
      userId: draft.userId,
      title: draft.title,
      addressText: draft.addressText,
      latitude: draft.latitude,
      longitude: draft.longitude,
      isDefault: draft.isDefault,
    );

    final existing = await _repository.forUser(normalized.userId);
    final makeDefault = normalized.isDefault || existing.isEmpty;

    final row = await _repository.insert(
      normalized,
      defaultFlag: AddressDefaultFlag(makeDefault),
    );

    if (makeDefault) {
      await _repository.clearDefaultsExcept(
        userId: normalized.userId,
        exceptId: row.id,
      );
    }
    return SavedAddress.fromRow(row);
  }

  Future<void> delete({
    required String id,
    required String userId,
  }) async {
    final existing = await requireForUser(userId: userId, id: id);
    await _repository.delete(id: id, userId: userId);
    if (!existing.isDefault) return;
    final remaining = await _repository.forUser(userId);
    if (remaining.isEmpty) return;
    await _repository.setDefault(id: remaining.first.id, userId: userId);
  }

  Future<void> setDefault({
    required String id,
    required String userId,
  }) async {
    await requireForUser(userId: userId, id: id);
    await _repository.setDefault(id: id, userId: userId);
    await _repository.clearDefaultsExcept(userId: userId, exceptId: id);
  }

  Future<double> deliveryFee({
    required String userId,
    required String businessId,
    required String addressId,
  }) async {
    if (userId.isEmpty || businessId.isEmpty || addressId.isEmpty) {
      return 0;
    }
    await requireForUser(userId: userId, id: addressId);
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
