import '../database.dart';

class CartItemsTable extends SupabaseTable<CartItemsRow> {
  @override
  String get tableName => 'cart_items';

  @override
  CartItemsRow createRow(Map<String, dynamic> data) => CartItemsRow(data);
}

class CartItemsRow extends SupabaseDataRow {
  CartItemsRow(super.data);

  @override
  SupabaseTable get table => CartItemsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get cartId => getField<String>('cart_id')!;
  set cartId(String value) => setField<String>('cart_id', value);

  String get productId => getField<String>('product_id')!;
  set productId(String value) => setField<String>('product_id', value);

  int get quantity => getField<int>('quantity')!;
  set quantity(int value) => setField<int>('quantity', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
