import '../database.dart';

class CartsTable extends SupabaseTable<CartsRow> {
  @override
  String get tableName => 'carts';

  @override
  CartsRow createRow(Map<String, dynamic> data) => CartsRow(data);
}

class CartsRow extends SupabaseDataRow {
  CartsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CartsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get businessId => getField<String>('business_id')!;
  set businessId(String value) => setField<String>('business_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
