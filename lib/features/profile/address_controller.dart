import 'package:degloor_one/backend/address_service.dart';
import 'package:degloor_one/shared/address_draft.dart';
import 'package:degloor_one/shared/saved_address.dart';

/// Profile screens talk to this controller, not [AddressService] or the
/// address repository.
class AddressController {
  AddressController({AddressService? service}) : _service = service;

  final AddressService? _service;

  static final instance = AddressController();

  AddressService get _resolved => _service ?? AddressService.instance;

  Future<List<SavedAddress>> listForUser(String userId) {
    return _resolved.listForUser(userId);
  }

  Future<SavedAddress> add(AddressDraft draft) {
    return _resolved.add(draft);
  }

  Future<void> delete({
    required String id,
    required String userId,
  }) {
    return _resolved.delete(id: id, userId: userId);
  }

  Future<void> setDefault({
    required String id,
    required String userId,
  }) {
    return _resolved.setDefault(id: id, userId: userId);
  }
}
