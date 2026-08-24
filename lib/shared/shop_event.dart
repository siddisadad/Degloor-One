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

  factory ShopEvent.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    final raw = json['metadata'];
    return ShopEvent(
      id: '${json['id'] ?? ''}',
      businessId: '${json['businessId'] ?? ''}',
      eventType: '${json['eventType'] ?? ''}',
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      userId: json['userId'] == null ? null : '${json['userId']}',
      metadata: raw is Map<String, dynamic> ? raw : null,
    );
  }
}
