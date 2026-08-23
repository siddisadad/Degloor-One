import 'package:degloor_one/backend/supabase/supabase.dart';

/// Reads and writes for `public.users`. Widgets and auth should go through
/// [UserService].
class UserRepository {
  Future<UsersRow?> byId(String userId) async {
    if (userId.isEmpty) return null;
    final rows = await UsersTable().queryRows(
      queryFn: (q) => q.eq('id', userId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<UsersRow>> byIds(List<String> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return UsersTable().queryRows(
      queryFn: (q) => q.inFilter('id', ids),
    );
  }

  Future<UsersRow> insert(Map<String, dynamic> data) {
    return UsersTable().insert(data);
  }

  Future<UsersRow?> update(String userId, Map<String, dynamic> data) async {
    if (userId.isEmpty || data.isEmpty) return byId(userId);
    final rows = await UsersTable().update(
      data: data,
      matchingRows: (q) => q.eq('id', userId),
      returnRows: true,
    );
    if (rows.isNotEmpty) return rows.first;
    return byId(userId);
  }

  Future<void> probe() async {
    await UsersTable().queryRows(
      queryFn: (q) => q,
      limit: 1,
    );
  }
}
