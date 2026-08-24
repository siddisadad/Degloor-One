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

  factory OrderStatusChange.fromJson(
    Map<String, dynamic> json, {
    required String orderId,
    int index = 0,
  }) {
    final created = json['createdAt'];
    final status = '${json['status'] ?? ''}';
    return OrderStatusChange(
      id: '${json['id'] ?? '$orderId-$status-$index'}',
      orderId: json['orderId'] == null ? orderId : '${json['orderId']}',
      status: status,
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      notes: json['notes'] as String?,
    );
  }
}
