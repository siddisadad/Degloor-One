/// Fields recorded when a shop analytics event is logged.
/// Id and createdAt stay off this type.
class ShopEventDraft {
  const ShopEventDraft({
    required this.businessId,
    required this.eventType,
    this.userId,
    this.metadata,
  });

  final String businessId;
  final String eventType;
  final String? userId;
  final Map<String, dynamic>? metadata;

  /// Table insert only. Never includes id or created_at.
  Map<String, dynamic> toInsertJson() {
    return {
      'business_id': businessId,
      'event_type': eventType,
      if (userId != null && userId!.isNotEmpty) 'user_id': userId,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
