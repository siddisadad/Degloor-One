import '../database.dart';

class ProductCategoriesTable extends SupabaseTable<ProductCategoriesRow> {
  @override
  String get tableName => 'product_categories';

  @override
  ProductCategoriesRow createRow(Map<String, dynamic> data) =>
      ProductCategoriesRow(data);
}

class ProductCategoriesRow extends SupabaseDataRow {
  ProductCategoriesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProductCategoriesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get businessId => getField<String>('business_id')!;
  set businessId(String value) => setField<String>('business_id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
