/// Fields a customer submits when reporting a listing.
/// Id and createdAt stay off this type. Status is the stored
/// pending value, not a client-invented state machine.
class ListingComplaintDraft {
  const ListingComplaintDraft({
    required this.userId,
    required this.businessId,
    required this.subject,
    required this.description,
    this.status = pending,
    this.orderId,
  });

  static const pending = 'pending';

  final String userId;
  final String businessId;
  final String subject;
  final String description;
  final String status;
  final String? orderId;

  /// Table insert only. Never includes id or created_at.
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'business_id': businessId,
      'subject': subject,
      'description': description,
      'status': status,
      if (orderId != null && orderId!.isNotEmpty) 'order_id': orderId,
    };
  }
}
