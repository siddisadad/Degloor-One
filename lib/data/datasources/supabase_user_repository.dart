import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/data/repositories/user_repository.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'package:degloor_one/shared/user_profile_draft.dart';

/// Showcase or live table access for `public.users`.
class SupabaseUserRepository implements UserRepository {
  UserProfile _toProfile(UsersRow row) {
    return UserProfile(
      id: row.id,
      email: row.email,
      fullName: row.fullName,
      avatarUrl: row.avatarUrl,
      role: row.role,
      phoneNumber: row.phoneNumber,
      createdAt: row.createdAt,
    );
  }

  @override
  Future<UserProfile?> byId(String userId) async {
    if (userId.isEmpty) return null;
    final rows = await UsersTable().queryRows(
      queryFn: (q) => q.eq('id', userId),
      limit: 1,
    );
    return rows.isEmpty ? null : _toProfile(rows.first);
  }

  @override
  Future<List<UserProfile>> byIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await UsersTable().queryRows(
      queryFn: (q) => q.inFilter('id', ids),
    );
    return rows.map(_toProfile).toList();
  }

  @override
  Future<UserProfile> insert(
    UserProfileDraft draft, {
    required String userId,
  }) async {
    final row = await UsersTable().insert(draft.toInsertJson(userId: userId));
    return _toProfile(row);
  }

  @override
  Future<UserProfile?> update(String userId, UserProfileDraft draft) async {
    final data = draft.toUpdateJson();
    if (userId.isEmpty || data.isEmpty) return byId(userId);
    final rows = await UsersTable().update(
      data: data,
      matchingRows: (q) => q.eq('id', userId),
      returnRows: true,
    );
    if (rows.isNotEmpty) return _toProfile(rows.first);
    return byId(userId);
  }

  @override
  Future<void> probe() async {
    await UsersTable().queryRows(
      queryFn: (q) => q,
      limit: 1,
    );
  }
}
