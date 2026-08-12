import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'database.dart';

abstract class SupabaseDataRow {
  SupabaseDataRow(this.data);

  SupabaseTable get table;
  Map<String, dynamic> data;

  String get tableName => table.tableName;

  T? getField<T>(String fieldName, [T? defaultValue]) =>
      _supaDeserialize<T>(data[fieldName]) ?? defaultValue;
  void setField<T>(String fieldName, T? value) =>
      data[fieldName] = supaSerialize<T>(value);
  List<T> getListField<T>(String fieldName) =>
      _supaDeserializeList<T>(data[fieldName]) ?? [];
  void setListField<T>(String fieldName, List<T>? value) =>
      data[fieldName] = supaSerializeList<T>(value);

  @override
  String toString() => '''
Table: $tableName
Row Data: {${data.isNotEmpty ? '\n' : ''}${data.entries.map((e) => '  (${e.value.runtimeType}) "${e.key}": ${e.value},\n').join()}}''';

  @override
  int get hashCode => Object.hash(
        tableName,
        Object.hashAllUnordered(
          data.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );

  @override
  bool operator ==(Object other) =>
      other is SupabaseDataRow && mapEquals(other.data, data);
}

dynamic supaSerialize<T>(T? value) {
  if (value == null) {
    return null;
  }

  if (T == DateTime) {
    return (value as DateTime).toIso8601String();
  } else if (T == PostgresTime) {
    return (value as PostgresTime).toIso8601String();
  } else if (T == LatLng) {
    final latLng = (value as LatLng);
    return {'lat': latLng.latitude, 'lng': latLng.longitude};
  } else {
    return value;
  }
}

List? supaSerializeList<T>(List<T>? value) =>
    value?.map((v) => supaSerialize<T>(v)).toList();

T? _supaDeserialize<T>(dynamic value) {
  if (value == null) {
    return null;
  }

  if (T == int) {
    return (value as num).round() as T?;
  } else if (T == double) {
    return (value as num).toDouble() as T?;
  } else if (T == DateTime) {
    return DateTime.tryParse(value as String)?.toLocal() as T?;
  } else if (T == PostgresTime) {
    return PostgresTime.tryParse(value as String) as T?;
  } else if (T == LatLng) {
    final latLng = value is Map ? value : json.decode(value) as Map;
    final lat = latLng['lat'] ?? latLng['latitude'];
    final lng = latLng['lng'] ?? latLng['longitude'];
    return lat is num && lng is num
        ? LatLng(lat.toDouble(), lng.toDouble()) as T?
        : null;
  } else {
    return value as T;
  }
}

List<T>? _supaDeserializeList<T>(dynamic value) => value is List
    ? value
        .map((v) => _supaDeserialize<T>(v))
        .where((v) => v != null)
        .map((v) => v as T)
        .toList()
    : null;
