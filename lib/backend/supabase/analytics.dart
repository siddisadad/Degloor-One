import 'package:degloor_one/backend/shop_service.dart';

Future<void> logBusinessEvent({
  required String businessId,
  required String eventType,
  Map<String, dynamic>? metadata,
}) {
  return ShopService.instance.trackEvent(
    businessId: businessId,
    eventType: eventType,
    metadata: metadata,
  );
}

class BusinessAnalyticsEvents {
  static const String profileView = ShopEvents.profileView;
  static const String callClick = ShopEvents.callClick;
  static const String whatsappClick = ShopEvents.whatsappClick;
  static const String directionsClick = ShopEvents.directionsClick;
  static const String shareClick = ShopEvents.shareClick;
  static const String reviewSubmitted = ShopEvents.reviewSubmitted;
  static const String productView = ShopEvents.productView;
}
