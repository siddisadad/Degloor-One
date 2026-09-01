import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/repositories/user_repository.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'package:degloor_one/shared/user_profile_draft.dart';

/// User access through the Java API. The live API is current-user scoped
/// (`GET`/`PUT /api/v1/users/me`); other ids stay unread until a public
/// profile endpoint exists. Table rows stay on the server.
class JavaUserRepository implements UserRepository {
  JavaUserRepository({JavaApiClient? client})
      : _client = client ?? JavaApiClient.instance;

  final JavaApiClient _client;

  static UserProfile fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return UserProfile(
      id: '${json['id'] ?? ''}',
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: created is String ? DateTime.tryParse(created) : null,
    );
  }

  Future<UserProfile> _me() async {
    final data = await _client.get('/api/v1/users/me');
    return fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<UserProfile?> _meOrNull() async {
    try {
      return await _me();
    } on JavaApiException catch (error) {
      if (error.code == 'USER_NOT_FOUND' || error.code.contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<UserProfile?> byId(String userId) async {
    if (userId.isEmpty) return null;
    final me = await _meOrNull();
    if (me == null || me.id != userId) return null;
    return me;
  }

  @override
  Future<List<UserProfile>> byIds(List<String> ids) async {
    final unique = ids.where((id) => id.isNotEmpty).toSet();
    if (unique.isEmpty) return const [];
    final me = await _meOrNull();
    if (me == null || !unique.contains(me.id)) return const [];
    return [me];
  }

  @override
  Future<UserProfile> insert(
    UserProfileDraft draft, {
    required String userId,
  }) async {
    final me = await _me();
    if (me.id != userId) {
      throw Exception('Unable to create your profile. Please try again.');
    }
    return me;
  }

  @override
  Future<UserProfile?> update(String userId, UserProfileDraft draft) async {
    if (userId.isEmpty) return null;
    final me = await _meOrNull();
    if (me == null || me.id != userId) return null;
    final data = await _client.put('/api/v1/users/me', {
      if (draft.fullName != null && draft.fullName!.isNotEmpty)
        'fullName': draft.fullName,
      if (draft.phoneNumber != null) 'phoneNumber': draft.phoneNumber,
      if (draft.avatarUrl != null) 'avatarUrl': draft.avatarUrl,
    });
    return fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<void> probe() async {
    await _client.probeHealth();
  }
}
