import '../database.dart';

class OrderStatusHistoryTable extends SupabaseTable<OrderStatusHistoryRow> {
  @override
  String get tableName => 'order_status_history';

  @override
  OrderStatusHistoryRow createRow(Map<String, dynamic> data) =>
      OrderStatusHistoryRow(data);
}

class OrderStatusHistoryRow extends SupabaseDataRow {
  OrderStatusHistoryRow(super.data);

  @override
  SupabaseTable get table => OrderStatusHistoryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get orderId => getField<String>('order_id')!;
  set orderId(String value) => setField<String>('order_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
