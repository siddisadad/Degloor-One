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

  /// Realtime is filtered to the signed-in user so the client does not
  /// subscribe to the whole notifications table.
  Stream<List<NotificationsRow>> watchForUser(String userId) {
    return NotificationsTable().stream(
      primaryKey: 'id',
      queryFn: (q) =>
          q.eq('user_id', userId).order('created_at', ascending: false),
    );
  }
}
