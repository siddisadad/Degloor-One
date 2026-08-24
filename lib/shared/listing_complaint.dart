/// Customer report about a listing. Screens use this instead of a table row.
class ListingComplaint {
  const ListingComplaint({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    this.orderId,
    this.businessId,
  });

  final String id;
  final String userId;
  final String subject;
  final String description;
  final String status;
  final DateTime createdAt;
  final String? orderId;
  final String? businessId;

  factory ListingComplaint.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return ListingComplaint(
      id: '${json['id'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      subject: '${json['subject'] ?? ''}',
      description: '${json['description'] ?? ''}',
      status: '${json['status'] ?? ''}',
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      orderId: json['orderId'] == null ? null : '${json['orderId']}',
      businessId: json['businessId'] == null ? null : '${json['businessId']}',
    );
  }
}
