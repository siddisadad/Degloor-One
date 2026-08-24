import 'package:degloor_one/shared/marketplace_joins.dart';

/// Customer or shop order. Screens use this instead of a table row.
class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.deliveryAddressId,
    this.deliveryFee,
    this.paymentMethod,
    this.deliveryOtp,
    this.user,
  });

  final String id;
  final String userId;
  final String businessId;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String? deliveryAddressId;
  final double? deliveryFee;
  final String? paymentMethod;
  final String? deliveryOtp;
  final DateTime createdAt;
  final JoinedUser? user;

  /// Java `OrderResponse`. Customer profile maps onto [JoinedUser].
  factory PlacedOrder.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return PlacedOrder(
      id: '${json['id'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      businessId: '${json['businessId'] ?? ''}',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: '${json['status'] ?? ''}',
      paymentStatus: '${json['paymentStatus'] ?? ''}',
      deliveryAddressId: json['deliveryAddressId'] == null
          ? null
          : '${json['deliveryAddressId']}',
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      paymentMethod: json['paymentMethod'] as String?,
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      user: JoinedUser.fromJoin(json['user'] ?? json['users']) ??
          JoinedUser.fromJoin(json),
    );
  }
}
