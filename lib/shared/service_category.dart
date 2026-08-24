/// Local service type. Screens use this instead of a table row.
class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    this.iconName,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? iconName;
  final DateTime? createdAt;

  /// Java `CategoryResponse`.
  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      iconName: json['iconName'] as String?,
    );
  }
}
