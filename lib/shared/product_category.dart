/// Per-shop product category. Screens use this instead of a table row.
class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.businessId,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String businessId;
  final String name;
  final DateTime createdAt;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return ProductCategory(
      id: '${json['id'] ?? ''}',
      businessId: '${json['businessId'] ?? ''}',
      name: '${json['name'] ?? ''}',
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
