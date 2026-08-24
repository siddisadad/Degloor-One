import 'package:degloor_one/backend/supabase/database/tables/delivery_assignments_table.dart';

/// Rider job for one order. Screens use this instead of [DeliveryAssignmentsRow].
class DeliveryAssignment {
  const DeliveryAssignment({
    required this.id,
    required this.orderId,
    required this.deliveryPartnerId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final String deliveryPartnerId;
  final String status;
  final DateTime createdAt;

  factory DeliveryAssignment.fromRow(DeliveryAssignmentsRow row) {
    return DeliveryAssignment(
      id: row.id,
      orderId: row.orderId,
      deliveryPartnerId: row.deliveryPartnerId,
      status: row.status,
      createdAt: row.createdAt,
    );
  }

  factory DeliveryAssignment.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return DeliveryAssignment(
      id: '${json['id'] ?? json['orderId'] ?? ''}',
      orderId: '${json['orderId'] ?? json['id'] ?? ''}',
      deliveryPartnerId:
          '${json['partnerId'] ?? json['deliveryPartnerId'] ?? ''}',
      status: '${json['status'] ?? 'assigned'}',
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
