import 'package:degloor_one/backend/supabase/database/tables/order_status_history_table.dart';

/// One status change on an order. Screens use this instead of
/// [OrderStatusHistoryRow].
class OrderStatusChange {
  const OrderStatusChange({
    required this.id,
    required this.orderId,
    required this.status,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final String orderId;
  final String status;
  final DateTime createdAt;
  final String? notes;

  factory OrderStatusChange.fromRow(OrderStatusHistoryRow row) {
    return OrderStatusChange(
      id: row.id,
      orderId: row.orderId,
      status: row.status,
      createdAt: row.createdAt,
      notes: row.notes,
    );
  }
}
