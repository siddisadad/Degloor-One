import 'package:degloor_one/backend/repositories/user_repository.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';

class UserService {
  UserService({UserRepository? repository})
      : _repository = repository ?? UserRepository();

  final UserRepository _repository;

  static final instance = UserService();

  Future<UsersRow?> byId(String userId) {
    if (userId.isEmpty) return Future<UsersRow?>.value();
    return _repository.byId(userId);
  }

  Future<List<UsersRow>> byIds(List<String> ids) {
    final unique = ids.where((id) => id.isNotEmpty).toSet().toList();
    if (unique.isEmpty) return Future.value(const []);
    return _repository.byIds(unique);
  }

  Future<List<UsersRow>> profile(String userId) async {
    final row = await byId(userId);
    return row == null ? const [] : [row];
  }

  Future<String?> roleFor(String userId) async {
    if (userId.isEmpty) return null;
    final row = await byId(userId);
    return row?.role;
  }

  Future<UsersRow> ensureOnSignIn({
    required String userId,
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Please sign in to continue');
    }
    final existing = await _repository.byId(userId);
    if (existing != null) return existing;
    return _repository.insert({
      'id': userId,
      'email': email,
      'phone_number': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': 'customer',
    });
  }

  Future<UsersRow> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Please sign in to update your profile');
    }
    final existing = await _repository.byId(userId);
    if (existing == null) {
      throw Exception('Profile not found');
    }
    final name = fullName?.trim();
    final phone = phoneNumber?.trim();
    if ((name == null || name.isEmpty) && phone == null) {
      throw Exception('Please fill your name or phone');
    }
    final updated = await _repository.update(userId, {
      if (name != null && name.isNotEmpty) 'full_name': name,
      if (phone != null) 'phone_number': phone,
    });
    if (updated == null) {
      throw Exception('Unable to update your profile. Please try again.');
    }
    return updated;
  }

  Future<void> probeReachable({
    Duration timeout = const Duration(seconds: 4),
  }) {
    return _repository.probe().timeout(timeout);
  }
}
