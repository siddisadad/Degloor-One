import 'database.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'showcase_query.dart';

abstract class SupabaseTable<T extends SupabaseDataRow> {
  String get tableName;
  T createRow(Map<String, dynamic> data);

  PostgrestFilterBuilder _select() => SupaFlow.client.from(tableName).select();

  Future<List<T>> queryRows({
    required dynamic Function(dynamic) queryFn,
    int? limit,
  }) async {
    if (kUseShowcaseData) {
      final captured = ShowcaseQuery();
      queryFn(captured);
      if (limit != null) captured.limit(limit);
      return ShowcaseCatalog.query(tableName, captured).map(createRow).toList();
    }
    try {
      final select = _select();
      var query = queryFn(select);
      query = limit != null ? query.limit(limit) : query;
      final rows = await query.select();
      return rows.map(createRow).toList();
    } catch (e) {
      AppLogger.error('Supabase queryRows error ($tableName)', e);
      rethrow;
    }
  }

  Future<List<T>> querySingleRow({
    required dynamic Function(dynamic) queryFn,
  }) async {
    if (kUseShowcaseData) {
      final captured = ShowcaseQuery()..limit(1);
      queryFn(captured);
      return ShowcaseCatalog.query(tableName, captured).map(createRow).toList();
    }
    try {
      final r = await queryFn(_select()).limit(1).select().maybeSingle();
      return [if (r != null) createRow(r)];
    } catch (e) {
      AppLogger.error('Supabase querySingleRow error ($tableName)', e);
      rethrow;
    }
  }

  Future<T> insert(Map<String, dynamic> data) {
    if (kUseShowcaseData) {
      return Future.value(createRow(ShowcaseCatalog.insert(tableName, data)));
    }
    try {
      return SupaFlow.client
          .from(tableName)
          .insert(data)
          .select()
          .limit(1)
          .single()
          .then(createRow);
    } catch (e) {
      AppLogger.error('Supabase insert error ($tableName)', e);
      rethrow;
    }
  }

  Future<List<T>> update({
    required Map<String, dynamic> data,
    required dynamic Function(dynamic) matchingRows,
    bool returnRows = false,
  }) async {
    if (kUseShowcaseData) {
      final captured = ShowcaseQuery();
      matchingRows(captured);
      return ShowcaseCatalog.update(tableName, data, captured)
          .map(createRow)
          .toList();
    }
    try {
      final update = matchingRows(SupaFlow.client.from(tableName).update(data));
      if (!returnRows) {
        await update;
        return [];
      }
      final rows = await update.select().then((rows) => rows.map(createRow).toList());
      return rows;
    } catch (e) {
      AppLogger.error('Supabase update error ($tableName)', e);
      rethrow;
    }
  }

  Future<List<T>> delete({
    required dynamic Function(dynamic) matchingRows,
    bool returnRows = false,
  }) async {
    if (kUseShowcaseData) {
      final captured = ShowcaseQuery();
      matchingRows(captured);
      return ShowcaseCatalog.delete(tableName, captured).map(createRow).toList();
    }
    try {
      final delete = matchingRows(SupaFlow.client.from(tableName).delete());
      if (!returnRows) {
        await delete;
        return [];
      }
      final rows = await delete.select().then((rows) => rows.map(createRow).toList());
      return rows;
    } catch (e) {
      AppLogger.error('Supabase delete error ($tableName)', e);
      rethrow;
    }
  }

  Future<void> upsert(List<Map<String, dynamic>> data) async {
    if (kUseShowcaseData) {
      for (final row in data) {
        ShowcaseCatalog.insert(tableName, row);
      }
      return;
    }
    try {
      await SupaFlow.client.from(tableName).upsert(data);
    } catch (e) {
      AppLogger.error('Supabase upsert error ($tableName)', e);
      rethrow;
    }
  }

  Stream<List<T>> stream({
    required String primaryKey,
    dynamic Function(dynamic)? queryFn,
  }) {
    if (kUseShowcaseData) {
      final captured = ShowcaseQuery();
      queryFn?.call(captured);
      return Stream<List<T>>.value(
        ShowcaseCatalog.query(tableName, captured).map(createRow).toList(),
      );
    }
    final builder = SupaFlow.client.from(tableName).stream(primaryKey: [primaryKey]);
    final stream = queryFn != null ? queryFn(builder) : builder;
    return stream.map((rows) => rows.map(createRow).toList());
  }
}

extension NullSafePostgrestFilters on PostgrestFilterBuilder {
  PostgrestFilterBuilder eqOrNull(String column, dynamic value) {
    return value != null ? eq(column, value) : this;
  }

  PostgrestFilterBuilder neqOrNull(String column, dynamic value) {
    return value != null ? neq(column, value) : this;
  }

  PostgrestFilterBuilder ltOrNull(String column, dynamic value) {
    return value != null ? lt(column, value) : this;
  }

  PostgrestFilterBuilder lteOrNull(String column, dynamic value) {
    return value != null ? lte(column, value) : this;
  }

  PostgrestFilterBuilder gtOrNull(String column, dynamic value) {
    return value != null ? gt(column, value) : this;
  }

  PostgrestFilterBuilder gteOrNull(String column, dynamic value) {
    return value != null ? gte(column, value) : this;
  }

  PostgrestFilterBuilder containsOrNull(String column, dynamic value) {
    return value != null ? contains(column, value) : this;
  }

  PostgrestFilterBuilder overlapsOrNull(String column, dynamic value) {
    return value != null ? overlaps(column, value) : this;
  }

  PostgrestFilterBuilder inFilterOrNull(String column, List<dynamic>? values) {
    return values != null ? inFilter(column, values) : this;
  }
}

extension NullSafeSupabaseStreamFilters on SupabaseStreamFilterBuilder {
  SupabaseStreamBuilder eqOrNull(String column, dynamic value) {
    return value != null ? eq(column, value) : this;
  }

  SupabaseStreamBuilder neqOrNull(String column, dynamic value) {
    return value != null ? neq(column, value) : this;
  }

  SupabaseStreamBuilder ltOrNull(String column, dynamic value) {
    return value != null ? lt(column, value) : this;
  }

  SupabaseStreamBuilder lteOrNull(String column, dynamic value) {
    return value != null ? lte(column, value) : this;
  }

  SupabaseStreamBuilder gtOrNull(String column, dynamic value) {
    return value != null ? gt(column, value) : this;
  }

  SupabaseStreamBuilder gteOrNull(String column, dynamic value) {
    return value != null ? gte(column, value) : this;
  }

  SupabaseStreamBuilder inFilterOrNull(String column, List<Object>? values) {
    return values != null ? inFilter(column, values) : this;
  }
}

class PostgresTime {
  PostgresTime(this.time);
  DateTime? time;

  static PostgresTime? tryParse(String formattedString) {
    final datePrefix = DateTime.now().toIso8601String().split('T').first;
    return PostgresTime(
        DateTime.tryParse('${datePrefix}T$formattedString')?.toLocal());
  }

  String? toIso8601String() {
    return time?.toIso8601String().split('T').last;
  }

  @override
  String toString() {
    return toIso8601String() ?? '';
  }
}
