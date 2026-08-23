import 'package:degloor_one/backend/supabase/database/tables/notifications_table.dart';

/// Inbox notice. Screens use this instead of [NotificationsRow].
class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.type,
  });

  final String id;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? type;

  factory AppNotification.fromRow(NotificationsRow row) {
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
}
