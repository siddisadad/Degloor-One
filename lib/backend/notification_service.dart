import 'package:degloor_one/backend/repositories/notification_repository.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/app_notification.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class NotificationService {
  NotificationService({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;

  static final instance = NotificationService();

  Future<PageResult<AppNotification>> listForUser(
    String userId, {
    PageQuery page = const PageQuery(),
  }) async {
    final rows = await _repository.forUser(userId, page: page);
    return PageResult(
      items: rows.map(AppNotification.fromRow).toList(),
      hasMore: rows.length >= page.limit,
    );
  }

  Future<int> unreadCount(String userId) => _repository.unreadCount(userId);

  Future<void> markRead({
    required String notificationId,
    required String userId,
  }) {
    return _repository.markRead(notificationId: notificationId, userId: userId);
  }

  Future<void> markAllRead(String userId) => _repository.markAllRead(userId);

  Future<void> clearAll(String userId) => _repository.deleteAll(userId);

  Stream<List<AppNotification>> watchForUser(String userId) {
    return _repository
        .watchForUser(userId)
        .map((rows) => rows.map(AppNotification.fromRow).toList());
  }

  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
  }) async {
    try {
      if (kUseShowcaseData) {
        ShowcaseCatalog.insert('notifications', {
          'user_id': userId,
          'title': title,
          'message': message,
          'type': type ?? 'general',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
        return;
      }
      // Live customer/owner inserts go through SECURITY DEFINER order RPCs.
    } catch (e) {
      AppLogger.error('Failed to send notification', e);
    }
  }

  /// Admin-only notify. Live path uses admin_notify_user().
  static Future<void> adminNotify({
    required String userId,
    required String title,
    required String message,
    String? type,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Missing recipient');
    }
    if (kUseShowcaseData) {
      await sendNotification(
        userId: userId,
        title: title,
        message: message,
        type: type,
      );
      return;
    }
    await SupaFlow.client.rpc(
      'admin_notify_user',
      params: {
        'p_user_id': userId,
        'p_title': title,
        'p_message': message,
        'p_type': type ?? 'general',
      },
    );
  }

  static Future<void> notifyOrderStatusUpdate({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    final shortId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
    await sendNotification(
      userId: userId,
      title: 'Order Updated',
      message: 'Your order #$shortId is now $status.',
      type: 'order_status',
    );
  }

  static Future<void> notifyNewReview({
    required String ownerId,
    required String businessName,
    required int rating,
  }) async {
    await sendNotification(
      userId: ownerId,
      title: 'New Review!',
      message: 'Someone left a $rating-star review for $businessName.',
      type: 'new_review',
    );
  }

  static Future<void> notifyServiceRequestUpdate({
    required String userId,
    required String status,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Service Request Update',
      message: 'Your service request is now $status.',
      type: 'service_request',
    );
  }
}
