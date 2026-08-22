import 'package:degloor_one/backend/repositories/notification_repository.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class NotificationService {
  static final repository = NotificationRepository();

  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
  }) async {
    try {
      if (!kUseShowcaseData) {
        // Live inserts go through SECURITY DEFINER RPCs only.
        return;
      }
      ShowcaseCatalog.insert('notifications', {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type ?? 'general',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('Failed to send notification', e);
    }
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
}
