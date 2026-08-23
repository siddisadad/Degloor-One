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
}
