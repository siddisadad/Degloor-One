import 'package:degloor_one/backend/supabase/database/tables/users_table.dart';

/// App user profile. Screens use this instead of [UsersRow].
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

  factory UserProfile.fromRow(UsersRow row) {
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
}
