/// Inbox notice. Screens use this instead of a table row.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.type,
  });

  final String id;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? type;

  /// Java `NotificationResponse`. [userId] is the signed-in inbox owner.
  factory AppNotification.fromJson(
    Map<String, dynamic> json, {
    required String userId,
  }) {
    final created = json['createdAt'];
    return AppNotification(
      id: '${json['id'] ?? ''}',
      userId: userId,
      title: '${json['title'] ?? ''}',
      message: '${json['message'] ?? ''}',
      isRead: json['read'] as bool? ?? json['isRead'] as bool? ?? false,
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      type: json['type'] as String?,
    );
  }
}
