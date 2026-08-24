import 'package:degloor_one/core/api/api_client.dart';

class NotificationApi {
  NotificationApi._();

  static final _http = JavaApiClient.instance;

  static Future<Map<String, dynamic>> list({int page = 0, int size = 20}) async {
    return Map<String, dynamic>.from(await _http.get('/api/v1/notifications', query: {
      'page': '$page',
      'size': '$size',
    }) as Map);
  }

  static Future<Map<String, dynamic>> unreadCount() async {
    return Map<String, dynamic>.from(
      await _http.get('/api/v1/notifications/unread-count') as Map,
    );
  }

  static Future<void> markRead(String id) =>
      _http.post('/api/v1/notifications/$id/read');

  /// Java has no delete-all. Inbox clear uses this too.
  static Future<void> markAllRead() => _http.post('/api/v1/notifications/read-all');
}
