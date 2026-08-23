import 'package:degloor_one/backend/repositories/user_repository.dart';
import 'package:degloor_one/shared/user_profile.dart';

class UserService {
  UserService({UserRepository? repository})
      : _repository = repository ?? UserRepository();

  final UserRepository _repository;

  static final instance = UserService();

  Future<UserProfile?> byId(String userId) async {
    if (userId.isEmpty) return null;
    final row = await _repository.byId(userId);
    return row == null ? null : UserProfile.fromRow(row);
  }

  Future<List<UserProfile>> byIds(List<String> ids) async {
    final unique = ids.where((id) => id.isNotEmpty).toSet().toList();
    if (unique.isEmpty) return const [];
    final rows = await _repository.byIds(unique);
    return rows.map(UserProfile.fromRow).toList();
  }

  Future<List<UserProfile>> profile(String userId) async {
    final row = await byId(userId);
    return row == null ? const [] : [row];
  }

  Future<String?> roleFor(String userId) async {
    if (userId.isEmpty) return null;
    final row = await byId(userId);
    return row?.role;
  }

  Future<UserProfile> ensureOnSignIn({
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
    if (existing != null) return UserProfile.fromRow(existing);
    final created = await _repository.insert({
      'id': userId,
      'email': email,
      'phone_number': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': 'customer',
    });
    return UserProfile.fromRow(created);
  }

  Future<UserProfile> updateProfile({
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
    return UserProfile.fromRow(updated);
  }

  Future<void> probeReachable({
    Duration timeout = const Duration(seconds: 4),
  }) {
    return _repository.probe().timeout(timeout);
  }
}
