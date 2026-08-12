import '../database.dart';

class DeliveryAssignmentsTable extends SupabaseTable<DeliveryAssignmentsRow> {
  @override
  String get tableName => 'delivery_assignments';

  @override
  DeliveryAssignmentsRow createRow(Map<String, dynamic> data) =>
      DeliveryAssignmentsRow(data);
}

class DeliveryAssignmentsRow extends SupabaseDataRow {
  DeliveryAssignmentsRow(super.data);

  @override
  SupabaseTable get table => DeliveryAssignmentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get orderId => getField<String>('order_id')!;
  set orderId(String value) => setField<String>('order_id', value);

  String get deliveryPartnerId => getField<String>('delivery_partner_id')!;
  set deliveryPartnerId(String value) =>
      setField<String>('delivery_partner_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
