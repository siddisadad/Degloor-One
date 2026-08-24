import 'package:degloor_one/data/repositories/user_repository.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'package:degloor_one/shared/user_profile_draft.dart';

class UserService {
  UserService({required UserRepository repository})
      : _repository = repository;

  final UserRepository _repository;

  static UserService? _instance;

  static UserService get instance {
    final bound = _instance;
    if (bound == null) {
      throw StateError('UserService is not bound.');
    }
    return bound;
  }

  /// Called from the composition root with a concrete repository.
  static void bind(UserRepository repository) {
    _instance = UserService(repository: repository);
  }

  Future<UserProfile?> byId(String userId) async {
    if (userId.isEmpty) return null;
    return _repository.byId(userId);
  }

  Future<List<UserProfile>> byIds(List<String> ids) async {
    final unique = ids.where((id) => id.isNotEmpty).toSet().toList();
    if (unique.isEmpty) return const [];
    return _repository.byIds(unique);
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
    required UserProfileDraft draft,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Please sign in to continue');
    }
    final existing = await _repository.byId(userId);
    if (existing != null) return existing;
    return _repository.insert(draft, userId: userId);
  }

  Future<UserProfile> updateProfile({
    required String userId,
    required UserProfileDraft draft,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Please sign in to update your profile');
    }
    final existing = await _repository.byId(userId);
    if (existing == null) {
      throw Exception('Profile not found');
    }
    final normalized = UserProfileDraft.fromProfile(
      fullName: draft.fullName,
      phoneNumber: draft.phoneNumber,
    );
    final updated = await _repository.update(userId, normalized);
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
