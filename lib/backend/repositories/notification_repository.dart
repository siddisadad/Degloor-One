import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';

class NotificationRepository {
  Future<List<NotificationsRow>> forUser(
    String userId, {
    PageQuery page = const PageQuery(),
  }) {
    return NotificationsTable().queryRows(
      queryFn: (q) =>
          q.eq('user_id', userId).order('created_at', ascending: false),
      limit: page.limit,
      offset: page.offset,
    );
  }

  Future<int> unreadCount(String userId) async {
    if (userId.isEmpty) return 0;
    if (kUseShowcaseData) {
      final rows = await NotificationsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).eq('is_read', false),
      );
      return rows.length;
    }
    final result = await SupaFlow.client.rpc('unread_notification_count');
    return (result as num?)?.toInt() ?? 0;
  }

  Future<void> markRead({
    required String notificationId,
    required String userId,
  }) async {
    await NotificationsTable().update(
      data: {'is_read': true},
      matchingRows: (q) => q.eq('id', notificationId).eq('user_id', userId),
    );
  }

  Future<void> markAllRead(String userId) async {
    await NotificationsTable().update(
      data: {'is_read': true},
      matchingRows: (q) => q.eq('user_id', userId).eq('is_read', false),
    );
  }

  Future<void> deleteAll(String userId) async {
    await NotificationsTable().delete(
      matchingRows: (q) => q.eq('user_id', userId),
    );
  }

  /// Realtime is a change signal for the signed-in user, not the inbox.
  Stream<List<NotificationsRow>> watchForUser(String userId) {
    return NotificationsTable().stream(
      primaryKey: 'id',
      queryFn: (q) =>
          q.eq('user_id', userId).order('created_at', ascending: false),
    );
  }
}
