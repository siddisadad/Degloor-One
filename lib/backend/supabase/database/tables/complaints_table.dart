import '../database.dart';

class ComplaintsTable extends SupabaseTable<ComplaintsRow> {
  @override
  String get tableName => 'complaints';

  @override
  ComplaintsRow createRow(Map<String, dynamic> data) => ComplaintsRow(data);
}

class ComplaintsRow extends SupabaseDataRow {
  ComplaintsRow(super.data);

  @override
  SupabaseTable get table => ComplaintsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get orderId => getField<String>('order_id');
  set orderId(String? value) => setField<String>('order_id', value);

  String? get businessId => getField<String>('business_id');
  set businessId(String? value) => setField<String>('business_id', value);

  String get subject => getField<String>('subject')!;
  set subject(String value) => setField<String>('subject', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
