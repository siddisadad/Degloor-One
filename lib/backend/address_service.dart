import 'package:degloor_one/backend/repositories/address_repository.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/error_handler.dart';
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

  Future<SavedAddress> add({
    required String userId,
    required String title,
    required String addressText,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    if (userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw Exception('Please pick a location on the map');
    }
    final trimmedTitle = title.trim();
    final trimmedAddress = addressText.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception('Please enter a title');
    }
    if (trimmedAddress.isEmpty) {
      throw Exception('Please enter address details');
    }

    final existing = await _repository.forUser(userId);
    final makeDefault = isDefault || existing.isEmpty;

    final row = await _repository.insert({
      'user_id': userId,
      'title': trimmedTitle,
      'address_text': trimmedAddress,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': makeDefault,
    });

    if (makeDefault) {
      await _repository.clearDefaultsExcept(
        userId: userId,
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
