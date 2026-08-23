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

  /// Postgres TIME text. Default matches the previous hours form.
  static String sqlTime(DateTime? time) {
    if (time == null) return '09:00:00';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  /// Table upsert only. [businessId] wins so an owner cannot write
  /// another shop's hours.
  Map<String, dynamic> toUpsertJson({required String businessId}) {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'business_id': businessId,
      'day_of_week': dayOfWeek,
      'open_time': sqlTime(openTime),
      'close_time': sqlTime(closeTime),
      'is_closed': isClosed,
    };
  }
}
