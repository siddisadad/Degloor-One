import 'package:degloor_one/backend/supabase/database/tables/business_hours_table.dart';

/// Weekly opening window. Screens use this instead of [BusinessHoursRow].
class ShopHours {
  ShopHours({
    this.id,
    this.businessId,
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.isClosed = false,
    this.createdAt,
  });

  String? id;
  String? businessId;
  int dayOfWeek;
  DateTime? openTime;
  DateTime? closeTime;
  bool isClosed;
  DateTime? createdAt;

  factory ShopHours.fromRow(BusinessHoursRow row) {
    final rawId = row.data['id'];
    return ShopHours(
      id: rawId == null || '$rawId'.isEmpty ? null : '$rawId',
      businessId: row.businessId,
      dayOfWeek: row.dayOfWeek,
      openTime: row.openTime?.time,
      closeTime: row.closeTime?.time,
      isClosed: row.isClosed,
      createdAt: row.createdAt,
    );
  }
}
