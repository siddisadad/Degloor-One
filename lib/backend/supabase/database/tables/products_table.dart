import 'package:flutter/foundation.dart';

import '../database.dart';
import 'package:degloor_one/backend/supabase/database/tables/businesses_table.dart';
import 'package:degloor_one/flutter_flow/lat_lng.dart';
import 'package:degloor_one/shared/search_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class ProductsTable extends SupabaseTable<ProductsRow> {
  @override
  String get tableName => 'products';

  @override
  ProductsRow createRow(Map<String, dynamic> data) => ProductsRow(data);

  /// Live project signature: `user_lat`, `user_lng`, `radius_meters`,
  /// optional `search_term`. Limit/offset are applied here.
  @visibleForTesting
  static Map<String, dynamic> liveSearchParams({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchTerm,
  }) {
    return {
      'user_lat': latitude,
      'user_lng': longitude,
      'radius_meters': radiusKm * 1000,
      if (searchTerm != null && searchTerm.isNotEmpty) 'search_term': searchTerm,
    };
  }

  @visibleForTesting
  static List<ProductsRow> applyLiveSearchFilters(
    List<ProductsRow> rows, {
    int limit = 20,
    int offset = 0,
  }) {
    var filtered = rows;
    if (offset > 0) {
      filtered = offset >= filtered.length
          ? <ProductsRow>[]
          : filtered.sublist(offset);
    }
    if (filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }
    return filtered;
  }

  /// Nearby rows from `public.products` using each shop's coordinates.
  /// Live search RPCs omit `distance_km` and Chrome yields `JSArray`.
  @visibleForTesting
  static List<ProductsRow> filterLiveTableRows(
    List<ProductsRow> products,
    List<BusinessesRow> shops, {
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchTerm,
    int limit = 20,
    int offset = 0,
  }) {
    final shopsById = {for (final shop in shops) shop.id: shop};
    final query = SearchQuery.parse(searchTerm);
    final matches = <ProductsRow>[];
    for (final product in products) {
      final shop = shopsById[product.businessId];
      if (shop == null) continue;
      final lat = shop.latitude;
      final lng = shop.longitude;
      if (lat == null || lng == null) continue;
      final distance = LatLng.distanceKm(latitude, longitude, lat, lng);
      if (distance > radiusKm) continue;
      if (!query.matches([product.name, product.description, shop.name])) {
        continue;
      }
      if (product.distanceKm == null) {
        product.distanceKm = double.parse(distance.toStringAsFixed(2));
      }
      matches.add(product);
    }
    matches.sort(
      (a, b) => (a.distanceKm ?? 1e9).compareTo(b.distanceKm ?? 1e9),
    );
    return applyLiveSearchFilters(matches, limit: limit, offset: offset);
  }

  Future<List<ProductsRow>> _searchLiveTable({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchTerm,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final products = await queryRows(queryFn: (q) => q);
      final shops = await BusinessesTable().queryRows(queryFn: (q) => q);
      return filterLiveTableRows(
        products,
        shops,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        searchTerm: searchTerm,
        limit: limit,
        offset: offset,
      );
    } catch (_) {
      return const [];
    }
  }

  Future<List<ProductsRow>> searchInRadius({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchTerm,
    int limit = 20,
    int offset = 0,
  }) async {
    if (kUseShowcaseData) {
      return ShowcaseCatalog.searchProducts(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        searchTerm: searchTerm,
        limit: limit,
        offset: offset,
      ).map(createRow).toList();
    }
    if (AppEnvironment.flutterFlowHostIsLive) {
      return _searchLiveTable(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        searchTerm: searchTerm,
        limit: limit,
        offset: offset,
      );
    }
    try {
      final dynamic raw = await SupaFlow.client.rpc(
        'search_products_in_radius',
        params: liveSearchParams(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
          searchTerm: searchTerm,
        ),
      );
      return applyLiveSearchFilters(
        rowsFromWire(raw),
        limit: limit,
        offset: offset,
      );
    } catch (_) {
      return _searchLiveTable(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        searchTerm: searchTerm,
        limit: limit,
        offset: offset,
      );
    }
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
