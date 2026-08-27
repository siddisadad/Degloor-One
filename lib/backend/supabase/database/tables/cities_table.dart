import '../database.dart';

class CitiesTable extends SupabaseTable<CitiesRow> {
  @override
  String get tableName => 'cities';

  @override
  CitiesRow createRow(Map<String, dynamic> data) => CitiesRow(data);
}

class CitiesRow extends SupabaseDataRow {
  CitiesRow(super.data);

  @override
  SupabaseTable get table => CitiesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get state => getField<String>('state');
  set state(String? value) => setField<String>('state', value);

  String? get district => getField<String>('district');
  set district(String? value) => setField<String>('district', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
