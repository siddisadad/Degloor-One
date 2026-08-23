import 'package:degloor_one/backend/supabase/database/tables/business_categories_table.dart';

/// Marketplace shop type. Screens use this instead of [BusinessCategoriesRow].
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

  factory ShopCategory.fromRow(BusinessCategoriesRow row) {
    final rawCreated = row.data['created_at'];
    DateTime? createdAt;
    if (rawCreated is DateTime) {
      createdAt = rawCreated;
    } else if (rawCreated != null) {
      createdAt = DateTime.tryParse('$rawCreated');
    }
    return ShopCategory(
      id: row.id,
      name: row.name,
      iconName: row.iconName,
      displayOrder: row.displayOrder,
      createdAt: createdAt,
    );
  }
}
