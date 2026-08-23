import 'package:degloor_one/backend/repositories/address_repository.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';

class AddressService {
  AddressService({AddressRepository? repository})
      : _repository = repository ?? AddressRepository();

  final AddressRepository _repository;

  static final instance = AddressService();

  static const _signInMessage = 'Please sign in to manage addresses';
  static const _missingMessage = 'Address not found';

  Future<List<AddressesRow>> listForUser(String userId) {
    if (userId.isEmpty) return Future.value(const []);
    return _repository.forUser(userId);
  }

  Future<AddressesRow> add({
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
    final trimmedTitle = title.trim();
    final trimmedAddress = addressText.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception('Please enter a title');
    }
    if (trimmedAddress.isEmpty) {
      throw Exception('Please enter address details');
    }

    final row = await _repository.insert({
      'user_id': userId,
      'title': trimmedTitle,
      'address_text': trimmedAddress,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    });

    if (isDefault) {
      await _repository.clearDefaultsExcept(
        userId: userId,
        exceptId: row.id,
      );
    }
    return row;
  }

  Future<void> delete({
    required String id,
    required String userId,
  }) async {
    if (userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    final existing = await _repository.forUserAndId(userId: userId, id: id);
    if (existing == null) {
      throw Exception(_missingMessage);
    }
    await _repository.delete(id: id, userId: userId);
  }

  Future<void> setDefault({
    required String id,
    required String userId,
  }) async {
    if (userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    final existing = await _repository.forUserAndId(userId: userId, id: id);
    if (existing == null) {
      throw Exception(_missingMessage);
    }
    await _repository.clearDefaults(userId);
    await _repository.setDefault(id: id, userId: userId);
  }
}
