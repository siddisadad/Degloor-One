import 'package:flutter/foundation.dart';

import '../database.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class BusinessesTable extends SupabaseTable<BusinessesRow> {
  @override
  String get tableName => 'businesses';

  @override
  BusinessesRow createRow(Map<String, dynamic> data) => BusinessesRow(data);

  /// Live project signature: `user_lat`, `user_lng`, `radius_meters`,
  /// optional `search_term` / `category_id`. Extra filters are applied here.
  @visibleForTesting
  static Map<String, dynamic> liveSearchParams({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchTerm,
    String? categoryId,
  }) {
    return {
      'user_lat': latitude,
      'user_lng': longitude,
      'radius_meters': radiusKm * 1000,
      if (searchTerm != null && searchTerm.isNotEmpty) 'search_term': searchTerm,
      if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
    };
  }

  @visibleForTesting
  static List<BusinessesRow> applyLiveSearchFilters(
    List<BusinessesRow> rows, {
    bool openNow = false,
    bool verifiedOnly = false,
    double minRating = 0.0,
    int limit = 20,
    int offset = 0,
  }) {
    var filtered = rows;
    if (openNow) {
      filtered = filtered.where((row) => row.isOpen == true).toList();
    }
    if (verifiedOnly) {
      filtered = filtered.where((row) => row.isVerified == true).toList();
    }
    if (minRating > 0) {
      filtered =
          filtered.where((row) => (row.rating ?? 0) >= minRating).toList();
    }
    if (offset > 0) {
      filtered = offset >= filtered.length
          ? <BusinessesRow>[]
          : filtered.sublist(offset);
    }
    if (filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }
    return filtered;
  }

  Future<List<BusinessesRow>> searchInRadius({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchTerm,
    String? categoryId,
    bool openNow = false,
    bool verifiedOnly = false,
    double minRating = 0.0,
    int limit = 20,
    int offset = 0,
  }) async {
    if (kUseShowcaseData) {
      return ShowcaseCatalog.searchBusinesses(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        searchTerm: searchTerm,
        categoryId: categoryId,
        openNow: openNow,
        verifiedOnly: verifiedOnly,
        minRating: minRating,
        limit: limit,
        offset: offset,
      ).map(createRow).toList();
    }
    final response = await SupaFlow.client.rpc(
      'search_businesses_in_radius',
      params: liveSearchParams(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        searchTerm: searchTerm,
        categoryId: categoryId,
      ),
    );
    final rows = (response as List?)
            ?.map((row) => createRow(Map<String, dynamic>.from(row as Map)))
            .toList() ??
        <BusinessesRow>[];
    return applyLiveSearchFilters(
      rows,
      openNow: openNow,
      verifiedOnly: verifiedOnly,
      minRating: minRating,
      limit: limit,
      offset: offset,
    );
  }
}

class BusinessesRow extends SupabaseDataRow {
  BusinessesRow(super.data);

  @override
  SupabaseTable get table => BusinessesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get ownerId => getField<String>('owner_id');
  set ownerId(String? value) => setField<String>('owner_id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get ownerName => getField<String>('owner_name');
  set ownerName(String? value) => setField<String>('owner_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get categoryId => getField<String>('category_id');
  set categoryId(String? value) => setField<String>('category_id', value);

  String? get cityId => getField<String>('city_id');
  set cityId(String? value) => setField<String>('city_id', value);

  String? get addressText => getField<String>('address_text');
  set addressText(String? value) => setField<String>('address_text', value);

  String? get whatsappNumber => getField<String>('whatsapp_number');
  set whatsappNumber(String? value) => setField<String>('whatsapp_number', value);

  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);

  double? get rating => getField<double>('rating');
  set rating(double? value) => setField<double>('rating', value);

  bool? get isOpen => getField<bool>('is_open');
  set isOpen(bool? value) => setField<bool>('is_open', value);

  bool? get isVerified => getField<bool>('is_verified');
  set isVerified(bool? value) => setField<bool>('is_verified', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get longitude => getField<double>('longitude');
  set longitude(double? value) => setField<double>('longitude', value);

  double? get discoveryRadius => getField<double>('discovery_radius');
  set discoveryRadius(double? value) => setField<double>('discovery_radius', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  double? get distanceKm => getField<double>('distance_km');
  set distanceKm(double? value) => setField<double>('distance_km', value);

  String? get subcategory => getField<String>('sub_category');
  set subcategory(String? value) => setField<String>('sub_category', value);

  String? get source => getField<String>('source');
  set source(String? value) => setField<String>('source', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
