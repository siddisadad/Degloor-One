/// Marketplace shop type. Screens use this instead of a table row.
class ShopCategory {
  const ShopCategory({
    required this.id,
    required this.name,
    this.iconName,
    this.displayOrder,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? iconName;
  final int? displayOrder;
  final DateTime? createdAt;

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return ShopCategory(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      iconName: json['iconName'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
      createdAt: created is String ? DateTime.tryParse(created) : null,
    );
  }
}
