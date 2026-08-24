import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/repositories/address_repository.dart';
import 'package:degloor_one/shared/address_default_flag.dart';
import 'package:degloor_one/shared/address_draft.dart';
import 'package:degloor_one/shared/saved_address.dart';

/// Address access through the Java API. Table rows stay on the server.
class JavaAddressRepository implements AddressRepository {
  JavaAddressRepository({JavaApiClient? client})
      : _client = client ?? JavaApiClient.instance;

  final JavaApiClient _client;

  static SavedAddress fromJson(Map<String, dynamic> json, String userId) {
    final created = json['createdAt'];
    return SavedAddress(
      id: '${json['id'] ?? ''}',
      userId: '${json['userId'] ?? userId}',
      title: json['title'] as String?,
      addressText: json['addressText'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: created is String ? DateTime.tryParse(created) : null,
    );
  }

  Map<String, dynamic> _body(
    AddressDraft draft, {
    AddressDefaultFlag? defaultFlag,
  }) {
    return {
      'title': draft.title,
      'addressText': draft.addressText,
      'latitude': draft.latitude,
      'longitude': draft.longitude,
      'isDefault': (defaultFlag ?? draft.defaultFlag).isDefault,
    };
  }

  @override
  Future<List<SavedAddress>> forUser(String userId) async {
    if (userId.isEmpty) return const [];
    final data = await _client.get('/api/v1/users/me/addresses');
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => fromJson(Map<String, dynamic>.from(row), userId))
        .toList();
  }

  @override
  Future<SavedAddress?> forUserAndId({
    required String userId,
    required String id,
  }) async {
    if (userId.isEmpty || id.isEmpty) return null;
    final rows = await forUser(userId);
    for (final row in rows) {
      if (row.id == id) return row;
    }
    return null;
  }

  @override
  Future<SavedAddress> insert(
    AddressDraft draft, {
    AddressDefaultFlag? defaultFlag,
  }) async {
    final data = await _client.post(
      '/api/v1/users/me/addresses',
      _body(draft, defaultFlag: defaultFlag),
    );
    return fromJson(Map<String, dynamic>.from(data as Map), draft.userId);
  }

  @override
  Future<void> clearDefaults(String userId) async {
    final rows = await forUser(userId);
    for (final row in rows) {
      if (!row.isDefault) continue;
      await _put(row, const AddressDefaultFlag(false));
    }
  }

  @override
  Future<void> clearDefaultsExcept({
    required String userId,
    required String exceptId,
  }) async {
    final rows = await forUser(userId);
    for (final row in rows) {
      if (row.id == exceptId || !row.isDefault) continue;
      await _put(row, const AddressDefaultFlag(false));
    }
  }

  @override
  Future<void> setDefault({
    required String id,
    required String userId,
  }) async {
    final row = await forUserAndId(userId: userId, id: id);
    if (row == null) return;
    await _put(row, const AddressDefaultFlag(true));
  }

  @override
  Future<void> delete({
    required String id,
    required String userId,
  }) async {
    if (id.isEmpty || userId.isEmpty) return;
    await _client.delete('/api/v1/users/me/addresses/$id');
  }

  @override
  Future<double> deliveryFee({
    required String businessId,
    required String addressId,
  }) async {
    if (businessId.isEmpty || addressId.isEmpty) return 0;
    final data = await _client.get(
      '/api/v1/users/me/addresses/$addressId/delivery-fee',
      query: {'businessId': businessId},
    );
    if (data is Map) {
      return (data['fee'] as num?)?.toDouble() ?? 0;
    }
    return (data as num?)?.toDouble() ?? 0;
  }

  Future<void> _put(SavedAddress row, AddressDefaultFlag defaultFlag) {
    return _client.put('/api/v1/users/me/addresses/${row.id}', {
      'title': row.title ?? 'Home',
      'addressText': row.addressText ?? '',
      'latitude': row.latitude ?? 0,
      'longitude': row.longitude ?? 0,
      'isDefault': defaultFlag.isDefault,
    });
  }
}
