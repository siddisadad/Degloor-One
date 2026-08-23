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
}
