import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';

enum BusinessEventType {
  PROFILE_VIEW,
  CALL_CLICK,
  WHATSAPP_CLICK,
  DIRECTIONS_CLICK,
  SHARE_CLICK,
  REVIEW_SUBMITTED,
}

Future<void> logBusinessEvent(
  String businessId,
  BusinessEventType type, {
  Map<String, dynamic>? metadata,
}) async {
  try {
    await BusinessAnalyticsTable().insert({
      'business_id': businessId,
      'user_id': currentUserUid.isEmpty ? null : currentUserUid,
      'event_type': type.name,
      'metadata': metadata ?? {},
    });
  } catch (e) {
    print('Error logging business event: $e');
  }
}
