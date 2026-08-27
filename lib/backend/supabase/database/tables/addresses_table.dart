import '../database.dart';

class AddressesTable extends SupabaseTable<AddressesRow> {
  @override
  String get tableName => 'addresses';

  @override
  AddressesRow createRow(Map<String, dynamic> data) => AddressesRow(data);
}

class AddressesRow extends SupabaseDataRow {
  AddressesRow(super.data);

  @override
  SupabaseTable get table => AddressesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get addressText => getField<String>('address_text');
  set addressText(String? value) => setField<String>('address_text', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get longitude => getField<double>('longitude');
  set longitude(double? value) => setField<double>('longitude', value);

  bool get isDefault => getField<bool>('is_default') ?? false;
  set isDefault(bool value) => setField<bool>('is_default', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
