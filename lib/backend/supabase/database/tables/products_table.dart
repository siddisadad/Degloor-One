import '../database.dart';

class ProductsTable extends SupabaseTable<ProductsRow> {
  @override
  String get tableName => 'products';

  @override
  ProductsRow createRow(Map<String, dynamic> data) => ProductsRow(data);

  Future<List<ProductsRow>> searchInRadius({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchTerm,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await SupaFlow.client.rpc(
      'search_products_in_radius',
      params: {
        'user_lat': latitude,
        'user_lng': longitude,
        'radius_meters': radiusKm * 1000,
        if (searchTerm != null && searchTerm.isNotEmpty) 'search_term': searchTerm,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return (response as List?)?.map((e) => createRow(e)).toList() ?? [];
  }
}

class ProductsRow extends SupabaseDataRow {
  ProductsRow(super.data);

  @override
  SupabaseTable get table => ProductsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get businessId => getField<String>('business_id')!;
  set businessId(String value) => setField<String>('business_id', value);

  String? get categoryId => getField<String>('category_id');
  set categoryId(String? value) => setField<String>('category_id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  double? get price => getField<double>('price');
  set price(double? value) => setField<double>('price', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  bool? get isAvailable => getField<bool>('is_available');
  set isAvailable(bool? value) => setField<bool>('is_available', value);

  int? get stockQuantity => getField<int>('stock_quantity');
  set stockQuantity(int? value) => setField<int>('stock_quantity', value);

  bool? get trackInventory => getField<bool>('track_inventory');
  set trackInventory(bool? value) => setField<bool>('track_inventory', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  double? get distanceKm => getField<double>('distance_km');
  set distanceKm(double? value) => setField<double>('distance_km', value);
}
