import '../database.dart';

class BusinessCategoriesTable extends SupabaseTable<BusinessCategoriesRow> {
  @override
  String get tableName => 'business_categories';

  @override
  BusinessCategoriesRow createRow(Map<String, dynamic> data) =>
      BusinessCategoriesRow(data);
}

class BusinessCategoriesRow extends SupabaseDataRow {
  BusinessCategoriesRow(super.data);

  @override
  SupabaseTable get table => BusinessCategoriesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get iconName => getField<String>('icon_name');
  set iconName(String? value) => setField<String>('icon_name', value);

  int? get displayOrder => getField<int>('display_order');
  set displayOrder(int? value) => setField<int>('display_order', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
