import 'package:degloor_one/backend/supabase/database/tables/order_status_history_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/orders_table.dart';
import 'package:degloor_one/shared/order_status_change.dart';
import 'package:degloor_one/shared/placed_order.dart';

PlacedOrder placedOrderFromRow(OrdersRow row) {
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

OrderStatusChange orderStatusChangeFromRow(OrderStatusHistoryRow row) {
  return OrderStatusChange(
    id: row.id,
    orderId: row.orderId,
    status: row.status,
    createdAt: row.createdAt,
    notes: row.notes,
  );
}
