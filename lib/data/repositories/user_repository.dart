import 'package:degloor_one/shared/user_profile.dart';
import 'package:degloor_one/shared/user_profile_draft.dart';

/// Data access for app user profiles. Auth and screens go through
/// [UserService]. Concrete implementations map table rows or API JSON.
abstract class UserRepository {
  Future<UserProfile?> byId(String userId);

  Future<List<UserProfile>> byIds(List<String> ids);

  Future<UserProfile> insert(
    UserProfileDraft draft, {
    required String userId,
  });

  Future<UserProfile?> update(String userId, UserProfileDraft draft);

  Future<void> probe();
}
