import 'package:degloor_one/backend/supabase/database/tables/notifications_table.dart';
import 'package:degloor_one/shared/app_notification.dart';

AppNotification appNotificationFromRow(NotificationsRow row) {
  return AppNotification(
    id: row.id,
    userId: row.userId,
    title: row.title,
    message: row.message,
    isRead: row.isRead,
    createdAt: row.createdAt,
    type: row.type,
  );
}
