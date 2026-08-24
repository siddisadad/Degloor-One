import 'package:degloor_one/shared/user_role.dart';

/// Fields submitted when creating or editing a user profile.
/// CreatedAt stays off this type. Auth user id and the stored
/// customer role are applied at insert only.
class UserProfileDraft {
  const UserProfileDraft({
    this.email,
    this.phoneNumber,
    this.fullName,
    this.avatarUrl,
    this.role = UserRole.customer,
  });

  final String? email;
  final String? phoneNumber;
  final String? fullName;
  final String? avatarUrl;
  final UserRole role;

  /// Auth metadata on first sign-in. Role stays off the caller.
  factory UserProfileDraft.fromSignIn({
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
  }) {
    return UserProfileDraft(
      email: email,
      phoneNumber: phone,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }

  /// Parse the profile form. Name and phone stay off the widget.
  factory UserProfileDraft.fromProfile({
    String? fullName,
    String? phoneNumber,
  }) {
    final name = fullName?.trim();
    final phone = phoneNumber?.trim();
    if ((name == null || name.isEmpty) && phone == null) {
      throw Exception('Please fill your name or phone');
    }
    return UserProfileDraft(
      fullName: name,
      phoneNumber: phone,
    );
  }

  /// Table insert only. Never includes created_at.
  /// [userId] is the signed-in auth uid. New rows stay customers,
  /// the same stored default as before.
  Map<String, dynamic> toInsertJson({required String userId}) {
    return {
      'id': userId,
      'email': email,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      ...role.toUpdateJson(),
    };
  }

  /// Profile edit fields only. Never includes id, email, role,
  /// avatar_url, or created_at.
  Map<String, dynamic> toUpdateJson() {
    return {
      if (fullName != null && fullName!.isNotEmpty) 'full_name': fullName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    };
  }
}
