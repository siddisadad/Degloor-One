import 'package:degloor_one/backend/supabase/database/tables/business_analytics_table.dart';

/// One shop analytics event. Screens use this instead of
/// [BusinessAnalyticsRow].
class ShopEvent {
  const ShopEvent({
    required this.id,
    required this.businessId,
    required this.eventType,
    required this.createdAt,
    this.userId,
    this.metadata,
  });

  final String id;
  final String businessId;
  final String eventType;
  final DateTime createdAt;
  final String? userId;
  final Map<String, dynamic>? metadata;

  factory ShopEvent.fromRow(BusinessAnalyticsRow row) {
    final raw = row.metadata;
    return ShopEvent(
      id: row.id,
      businessId: row.businessId,
      eventType: row.eventType,
      createdAt: row.createdAt,
      userId: row.userId,
      metadata: raw is Map<String, dynamic> ? raw : null,
    );
  }
}
