/// App user profile. Screens use this instead of a table row.
class UserProfile {
  const UserProfile({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.role,
    this.phoneNumber,
    this.createdAt,
  });

  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String? role;
  final String? phoneNumber;
  final DateTime? createdAt;
}
