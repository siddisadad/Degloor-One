/// One shop analytics event. Screens use this instead of a table row.
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

class ShopEvents {
  static const profileView = 'PROFILE_VIEW';
  static const callClick = 'CALL_CLICK';
  static const whatsappClick = 'WHATSAPP_CLICK';
  static const directionsClick = 'DIRECTIONS_CLICK';
  static const shareClick = 'SHARE_CLICK';
  static const reviewSubmitted = 'REVIEW_SUBMITTED';
  static const productView = 'PRODUCT_VIEW';
}
