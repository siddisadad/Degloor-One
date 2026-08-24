import 'package:degloor_one/shared/shop_event.dart';

/// Expand Java `GET /businesses/{id}/insights` counts into events so
/// [ShopService.summarizeEvents] still works without a list endpoint.
List<ShopEvent> shopEventsFromInsights(
  String businessId,
  Map<String, dynamic> insights,
) {
  final now = DateTime.now();
  ShopEvent event(String type, int index) {
    return ShopEvent(
      id: '$businessId-$type-$index',
      businessId: businessId,
      eventType: type,
      createdAt: now,
    );
  }

  int count(String key) => (insights[key] as num?)?.toInt() ?? 0;
  return [
    for (var i = 0; i < count('profileViews'); i++)
      event(ShopEvents.profileView, i),
    for (var i = 0; i < count('calls'); i++) event(ShopEvents.callClick, i),
    for (var i = 0; i < count('whatsapp'); i++)
      event(ShopEvents.whatsappClick, i),
    for (var i = 0; i < count('reviews'); i++)
      event(ShopEvents.reviewSubmitted, i),
  ];
}
