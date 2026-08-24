import 'package:degloor_one/backend/supabase/database/tables/products_table.dart';

/// Shop catalogue listing. Screens use this instead of [ProductsRow].
///
/// [price] is a display snapshot. Checkout ignores client-supplied prices.
class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.businessId,
    required this.name,
    required this.createdAt,
    this.categoryId,
    this.description,
    this.price,
    this.imageUrl,
    this.isAvailable,
    this.stockQuantity,
    this.trackInventory,
    this.distanceKm,
  });

  final String id;
  final String businessId;
  final String name;
  final DateTime createdAt;
  final String? categoryId;
  final String? description;
  final double? price;
  final String? imageUrl;
  final bool? isAvailable;
  final int? stockQuantity;
  final bool? trackInventory;
  final double? distanceKm;

  factory CatalogProduct.fromRow(ProductsRow row) {
    return CatalogProduct(
      id: row.id,
      businessId: row.businessId,
      name: row.name,
      createdAt: row.createdAt,
      categoryId: row.categoryId,
      description: row.description,
      price: row.price,
      imageUrl: row.imageUrl,
      isAvailable: row.isAvailable,
      stockQuantity: row.stockQuantity,
      trackInventory: row.trackInventory,
      distanceKm: row.distanceKm,
    );
  }

  factory CatalogProduct.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return CatalogProduct(
      id: '${json['id'] ?? ''}',
      businessId: '${json['businessId'] ?? ''}',
      name: '${json['name'] ?? ''}',
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      categoryId: json['categoryId'] == null ? null : '${json['categoryId']}',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['available'] as bool? ?? json['isAvailable'] as bool?,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt(),
      trackInventory: json['trackInventory'] as bool?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }
}
