/// One-field user role write.
/// Id, email, and createdAt stay off this type.
class UserRole {
  const UserRole(this.value);

  /// Stored sign-in default. Not a client-invented role.
  static const customer = UserRole('customer');

  /// Shop registration. Java promotes a customer on shop create; showcase
  /// writes this locally so the dashboard route works.
  static const businessOwner = UserRole('business_owner');

  /// Service registration. Local leftover when live `users` cannot promote.
  static const serviceProvider = UserRole('service_provider');

  static const admin = UserRole('admin');

  final String value;

  bool get isCustomer => value == customer.value;
  bool get isBusinessOwner => value == businessOwner.value;
  bool get isServiceProvider => value == serviceProvider.value;

  /// Profile / settings label. Distinct from the person's name.
  String get label => switch (value) {
        'business_owner' => 'Business owner',
        'service_provider' => 'Service provider',
        'admin' => 'Admin',
        _ => 'Customer',
      };

  static UserRole parse(String? raw) {
    switch ((raw ?? '').trim()) {
      case 'business_owner':
        return businessOwner;
      case 'service_provider':
        return serviceProvider;
      case 'admin':
        return admin;
      default:
        return customer;
    }
  }

  /// Table update only. Never includes id, email, or created_at.
  Map<String, dynamic> toUpdateJson() {
    return {'role': value};
  }
}
