import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';

Future logBusinessEvent({
  required String businessId,
  required String eventType,
  Map<String, dynamic>? metadata,
}) async {
  try {
    await BusinessAnalyticsTable().logEvent(
      businessId: businessId,
      eventType: eventType,
      userId: currentUserUid,
      metadata: metadata,
    );
  } catch (e) {
    // Fail silently in production to avoid interrupting UX
    print('Analytics Error ($eventType): $e');
  }
}

class BusinessAnalyticsEvents {
  static const String profileView = 'PROFILE_VIEW';
  static const String callClick = 'CALL_CLICK';
  static const String whatsappClick = 'WHATSAPP_CLICK';
  static const String directionsClick = 'DIRECTIONS_CLICK';
  static const String shareClick = 'SHARE_CLICK';
  static const String reviewSubmitted = 'REVIEW_SUBMITTED';
}
