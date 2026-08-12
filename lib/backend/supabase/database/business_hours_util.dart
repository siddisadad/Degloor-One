import 'package:degloor_one/core/error_handler.dart';

import 'database.dart';

Future<bool> getBusinessOpenStatus(String businessId) async {
  final now = DateTime.now();
  final dayOfWeek = now.weekday % 7; // 0=Sunday, 1=Monday, ..., 6=Saturday

  try {
    final hours = await BusinessHoursTable().queryRows(
      queryFn: (q) => q.eq('business_id', businessId).eq('day_of_week', dayOfWeek),
    );

    if (hours.isEmpty) return false;
    final row = hours.first;
    if (row.isClosed) return false;

    if (row.openTime?.time == null || row.closeTime?.time == null) return false;

    final open = row.openTime!.time!;
    final close = row.closeTime!.time!;

    final currentTime = now.hour * 60 + now.minute;
    final openTime = open.hour * 60 + open.minute;
    final closeTime = close.hour * 60 + close.minute;

    if (closeTime > openTime) {
      return currentTime >= openTime && currentTime <= closeTime;
    } else {
      // Handles overnight hours (e.g., 10 PM to 2 AM)
      return currentTime >= openTime || currentTime <= closeTime;
    }
  } catch (e) {
    AppLogger.error('Error checking business open status', e);
    return false;
  }
}

Future<Map<String, bool>> getMultipleBusinessesOpenStatus(
    List<String> businessIds) async {
  if (businessIds.isEmpty) return {};

  final now = DateTime.now();
  final dayOfWeek = now.weekday % 7;

  try {
    final hours = await BusinessHoursTable().queryRows(
      queryFn: (q) =>
          q.inFilter('business_id', businessIds).eq('day_of_week', dayOfWeek),
    );

    final statusMap = <String, bool>{};
    for (var id in businessIds) {
      statusMap[id] = false;
    }

    final currentTime = now.hour * 60 + now.minute;

    for (final row in hours) {
      if (row.isClosed) continue;
      if (row.openTime?.time == null || row.closeTime?.time == null) continue;

      final openTime =
          row.openTime!.time!.hour * 60 + row.openTime!.time!.minute;
      final closeTime =
          row.closeTime!.time!.hour * 60 + row.closeTime!.time!.minute;

      bool isOpen = false;
      if (closeTime > openTime) {
        isOpen = currentTime >= openTime && currentTime <= closeTime;
      } else {
        isOpen = currentTime >= openTime || currentTime <= closeTime;
      }

      if (isOpen) {
        statusMap[row.businessId!] = true;
      }
    }
    return statusMap;
  } catch (e) {
    AppLogger.error('Error checking multiple business open statuses', e);
    return {for (var id in businessIds) id: false};
  }
}
