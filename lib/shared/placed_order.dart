import 'package:degloor_one/backend/supabase/database/tables/orders_table.dart';

/// Customer or shop order. Screens use this instead of [OrdersRow].
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

  factory PlacedOrder.fromRow(OrdersRow row) {
    return PlacedOrder(
      id: row.id,
      userId: row.userId,
      businessId: row.businessId,
      totalAmount: row.totalAmount,
      status: row.status,
      paymentStatus: row.paymentStatus,
      deliveryAddressId: row.deliveryAddressId,
      deliveryFee: row.deliveryFee,
      paymentMethod: row.paymentMethod,
      deliveryOtp: row.deliveryOtp,
      createdAt: row.createdAt,
    );
  }
}
