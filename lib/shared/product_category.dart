import 'package:degloor_one/backend/supabase/database/tables/product_categories_table.dart';

/// Per-shop product category. Screens use this instead of [ProductCategoriesRow].
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

  factory ProductCategory.fromRow(ProductCategoriesRow row) {
    return ProductCategory(
      id: row.id,
      businessId: row.businessId,
      name: row.name,
      createdAt: row.createdAt,
    );
  }
}
