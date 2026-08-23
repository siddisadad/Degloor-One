import 'package:degloor_one/backend/supabase/database/tables/service_categories_table.dart';

/// Local service type. Screens use this instead of [ServiceCategoriesRow].
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

  factory ServiceCategory.fromRow(ServiceCategoriesRow row) {
    final rawCreated = row.data['created_at'];
    DateTime? createdAt;
    if (rawCreated is DateTime) {
      createdAt = rawCreated;
    } else if (rawCreated != null) {
      createdAt = DateTime.tryParse('$rawCreated');
    }
    return ServiceCategory(
      id: row.id,
      name: row.name,
      iconName: row.iconName,
      createdAt: createdAt,
    );
  }
}
