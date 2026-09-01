import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/repositories/notification_repository.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/core/api/notification_api.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/data/datasources/supabase_notification_maps.dart';
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
    if (userId.isEmpty) {
      return const PageResult(items: [], hasMore: false);
    }
    if (JavaApiConfig.enabled) {
      final data = await NotificationApi.list(
        page: _javaPage(page),
        size: page.limit,
      );
      final items = [
        for (final row in _pageItems(data))
          AppNotification.fromJson(row, userId: userId),
      ];
      return PageResult(
        items: items,
        hasMore: data['hasMore'] == true,
      );
    }
    final rows = await _repository.forUser(userId, page: page);
    return PageResult(
      items: rows.map(appNotificationFromRow).toList(),
      hasMore: rows.length >= page.limit,
    );
  }

  Future<int> unreadCount(String userId) async {
    if (userId.isEmpty) return 0;
    if (JavaApiConfig.enabled) {
      final data = await NotificationApi.unreadCount();
      return (data['count'] as num?)?.toInt() ?? 0;
    }
    return _repository.unreadCount(userId);
  }

  Future<void> markRead({
    required String notificationId,
    required String userId,
  }) {
    if (JavaApiConfig.enabled) {
      return NotificationApi.markRead(notificationId);
    }
    return _repository.markRead(notificationId: notificationId, userId: userId);
  }

  Future<void> markAllRead(String userId) {
    if (JavaApiConfig.enabled) {
      return NotificationApi.markAllRead();
    }
    return _repository.markAllRead(userId);
  }

  Future<void> clearAll(String userId) {
    if (JavaApiConfig.enabled) {
      // Java has no delete-all. Clear marks every notice read.
      return NotificationApi.markAllRead();
    }
    return _repository.deleteAll(userId);
  }

  Future<void> updateFcmToken(String token) async {
    final user = currentUserUid;
    if (user == '') return;
    if (JavaApiConfig.enabled || kUseShowcaseData) return;
    try {
      await SupaFlow.client.from('users').update({
        'fcm_token': token,
      }).eq('id', user);
    } catch (e) {
      AppLogger.error('Failed to update FCM token', e);
    }
  }

  Stream<List<AppNotification>> watchForUser(String userId) {
    if (JavaApiConfig.enabled) {
      return Stream.fromFuture(
        listForUser(userId).then((page) => page.items),
      );
    }
    return _repository
        .watchForUser(userId)
        .map((rows) => rows.map(appNotificationFromRow).toList());
  }

  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    String? referenceId,
  }) async {
    try {
      if (kUseShowcaseData) {
        ShowcaseCatalog.insert('notifications', {
          'user_id': userId,
          'title': title,
          'message': message,
          'type': type ?? 'general',
          'reference_id': referenceId,
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
    String? referenceId,
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
        referenceId: referenceId,
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
        'p_reference_id': referenceId,
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
      referenceId: orderId,
    );
  }

  static Future<void> notifyNewReview({
    required String ownerId,
    required String businessName,
    required int rating,
    String? businessId,
  }) async {
    await sendNotification(
      userId: ownerId,
      title: 'New Review!',
      message: 'Someone left a $rating-star review for $businessName.',
      type: 'new_review',
      referenceId: businessId,
    );
  }

  static Future<void> notifyServiceRequestUpdate({
    required String userId,
    required String status,
    String? requestId,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Service Request Update',
      message: 'Your service request is now $status.',
      type: 'service_request',
      referenceId: requestId,
    );
  }
}

int _javaPage(PageQuery page) {
  if (page.limit <= 0) return 0;
  return page.offset ~/ page.limit;
}

List<Map<String, dynamic>> _pageItems(Map<String, dynamic> data) {
  final raw = data['items'];
  final rows = raw is List ? raw : const [];
  return [
    for (final row in rows.whereType<Map>()) Map<String, dynamic>.from(row),
  ];
}

