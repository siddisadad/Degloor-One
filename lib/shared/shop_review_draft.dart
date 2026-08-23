/// Fields a customer submits when writing a shop review.
/// Id, createdAt, and the reviewer join stay off this type.
class ShopReviewDraft {
  const ShopReviewDraft({
    required this.userId,
    required this.businessId,
    required this.rating,
    this.comment = '',
    this.orderId,
  });

  final String userId;
  final String businessId;
  final int rating;
  final String comment;
  final String? orderId;

  /// Table insert only. Never includes id or created_at.
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'business_id': businessId,
      'rating': rating,
      'comment': comment,
      if (orderId != null && orderId!.isNotEmpty) 'order_id': orderId,
    };
  }
}
