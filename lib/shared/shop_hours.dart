/// Weekly opening window. Screens use this instead of a table row.
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

  /// Java `HoursResponse` (`openTime`/`closeTime` as `HH:mm:ss`, `closed`).
  factory ShopHours.fromJson(Map<String, dynamic> json) {
    return ShopHours(
      id: json['id'] == null || '${json['id']}'.isEmpty
          ? null
          : '${json['id']}',
      businessId: json['businessId'] == null ? null : '${json['businessId']}',
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 0,
      openTime: parseClock(json['openTime']),
      closeTime: parseClock(json['closeTime']),
      isClosed: json['closed'] as bool? ?? json['isClosed'] as bool? ?? false,
    );
  }

  static DateTime? parseClock(dynamic value) {
    if (value is DateTime) return value;
    if (value is! String || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(1970, 1, 1, hour, minute);
  }

  /// Weekday is Sunday=0 (`DateTime.weekday % 7`). Overnight windows
  /// (`close <= open`) wrap midnight. Empty / closed / missing times are closed.
  static bool isOpenNow(List<ShopHours> hours, {DateTime? now}) {
    final at = now ?? DateTime.now();
    final dayOfWeek = at.weekday % 7;
    final currentMinutes = at.hour * 60 + at.minute;
    for (final row in hours) {
      if (row.dayOfWeek != dayOfWeek) continue;
      if (row.isClosed) return false;
      final open = row.openTime;
      final close = row.closeTime;
      if (open == null || close == null) return false;
      final openMinutes = open.hour * 60 + open.minute;
      final closeMinutes = close.hour * 60 + close.minute;
      if (closeMinutes > openMinutes) {
        return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
      }
      return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
    }
    return false;
  }

  Map<String, dynamic> toHoursRequestJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': sqlTime(openTime),
      'closeTime': sqlTime(closeTime),
      'closed': isClosed,
    };
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
