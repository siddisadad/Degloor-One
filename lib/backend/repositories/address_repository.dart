import 'package:degloor_one/backend/supabase/supabase.dart';

/// Data access for saved customer addresses. Widgets should go through
/// [AddressService].
class AddressRepository {
  Future<List<AddressesRow>> forUser(String userId) {
    if (userId.isEmpty) return Future.value(const []);
    return AddressesTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId).order('created_at', ascending: false),
    );
  }

  Future<AddressesRow?> forUserAndId({
    required String userId,
    required String id,
  }) async {
    if (userId.isEmpty || id.isEmpty) return null;
    final rows = await AddressesTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId).eq('id', id),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<AddressesRow> insert(Map<String, dynamic> data) {
    return AddressesTable().insert(data);
  }

  Future<void> clearDefaults(String userId) async {
    if (userId.isEmpty) return;
    await AddressesTable().update(
      data: {'is_default': false},
      matchingRows: (q) => q.eq('user_id', userId),
    );
  }

  Future<void> clearDefaultsExcept({
    required String userId,
    required String exceptId,
  }) async {
    if (userId.isEmpty || exceptId.isEmpty) return;
    await AddressesTable().update(
      data: {'is_default': false},
      matchingRows: (q) => q.eq('user_id', userId).neq('id', exceptId),
    );
  }

  Future<void> setDefault({
    required String id,
    required String userId,
  }) async {
    if (id.isEmpty || userId.isEmpty) return;
    await AddressesTable().update(
      data: {'is_default': true},
      matchingRows: (q) => q.eq('id', id).eq('user_id', userId),
    );
  }

  Future<void> delete({
    required String id,
    required String userId,
  }) async {
    if (id.isEmpty || userId.isEmpty) return;
    await AddressesTable().delete(
      matchingRows: (q) => q.eq('id', id).eq('user_id', userId),
    );
  }
}
