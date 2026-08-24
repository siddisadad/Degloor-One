/// One-field user role write.
/// Id, email, and createdAt stay off this type.
class UserRole {
  const UserRole(this.value);

  /// Stored sign-in default. Not a client-invented role.
  static const customer = UserRole('customer');

  /// Showcase shop registration. Live RLS still blocks client role changes.
  static const businessOwner = UserRole('business_owner');

  final String value;

  /// Table update only. Never includes id, email, or created_at.
  Map<String, dynamic> toUpdateJson() {
    return {'role': value};
  }
}
