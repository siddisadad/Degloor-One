import 'package:degloor_one/data/repositories/address_repository.dart';
import 'package:degloor_one/shared/address_default_flag.dart';
import 'package:degloor_one/shared/address_draft.dart';
import 'package:degloor_one/shared/saved_address.dart';

class AddressService {
  AddressService({required AddressRepository repository})
      : _repository = repository;

  final AddressRepository _repository;

  static AddressService? _instance;

  static AddressService get instance {
    final bound = _instance;
    if (bound == null) {
      throw StateError('AddressService is not bound.');
    }
    return bound;
  }

  /// Called from the composition root with a concrete repository.
  static void bind(AddressRepository repository) {
    _instance = AddressService(repository: repository);
  }

  static const _signInMessage = 'Please sign in to manage addresses';
  static const _missingMessage = 'Address not found';

  Future<List<SavedAddress>> listForUser(String userId) async {
    if (userId.isEmpty) return const [];
    return _repository.forUser(userId);
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
    return row;
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

    final saved = await _repository.insert(
      normalized,
      defaultFlag: AddressDefaultFlag(makeDefault),
    );

    if (makeDefault) {
      await _repository.clearDefaultsExcept(
        userId: normalized.userId,
        exceptId: saved.id,
      );
    }
    return saved;
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
    return _repository.deliveryFee(
      businessId: businessId,
      addressId: addressId,
    );
  }
}
