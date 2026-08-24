import 'package:degloor_one/shared/marketplace_joins.dart';

/// Booking between a customer and a provider. Screens use this instead of
/// a table row.
class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.createdAt,
    this.userId,
    this.providerId,
    this.description,
    this.status,
    this.scheduledAt,
    this.user,
  });

  final String id;
  final DateTime createdAt;
  final String? userId;
  final String? providerId;
  final String? description;
  final String? status;
  final DateTime? scheduledAt;
  final JoinedUser? user;

  /// Joined customer avatar, or null when the request has no photo.
  String? get photoUrl {
    final url = user?.avatarUrl?.trim();
    if (url == null || url.isEmpty) return null;
    return url;
  }

  /// Java `RequestResponse`. Customer profile maps onto [JoinedUser].
  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic value) {
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return ServiceRequest(
      id: '${json['id'] ?? ''}',
      createdAt:
          parse(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      userId: json['userId'] == null ? null : '${json['userId']}',
      providerId: json['providerId'] == null ? null : '${json['providerId']}',
      description: json['description'] as String?,
      status: json['status'] as String?,
      scheduledAt: parse(json['scheduledAt']),
      user: JoinedUser.fromJoin(json['user'] ?? json['users']) ??
          JoinedUser.fromJoin(json),
    );
  }
}
