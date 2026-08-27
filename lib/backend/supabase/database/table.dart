import 'database.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'showcase_query.dart';

abstract class SupabaseTable<T extends SupabaseDataRow> {
  String get tableName;
  T createRow(Map<String, dynamic> data);

  PostgrestFilterBuilder _select() => SupaFlow.client.from(tableName).select();

  dynamic _applyPage(dynamic query, int? limit, int? offset) {
    if (offset != null && limit != null) {
      return query.range(offset, offset + limit - 1);
    }
    if (limit != null) {
      return query.limit(limit);
    }
    return query;
  }

  /// Chrome PostgREST payloads are `JSArray` / `Map<dynamic, dynamic>`.
  List<T> rowsFromWire(dynamic raw) {
    if (raw is! List) return const [];
    return [
      for (final row in raw)
        if (row is Map) createRow(Map<String, dynamic>.from(row)),
    ];
  }

  T? rowFromWire(dynamic raw) {
    if (raw is Map) return createRow(Map<String, dynamic>.from(raw));
    return null;
  }

  Future<List<T>> queryRows({
    required dynamic Function(dynamic) queryFn,
    int? limit,
    int? offset,
  }) async {
    if (kUseShowcaseData) {
      final captured = ShowcaseQuery();
      queryFn(captured);
      if (offset != null) captured.offsetCount = offset;
      if (limit != null) captured.limit(limit);
      return ShowcaseCatalog.query(tableName, captured).map(createRow).toList();
    }
    try {
      // `_select()` already called `.select()`. A second `.select()` is
      // inferred as `Future<List<T>>` (e.g. `List<UsersRow>`), and Chrome
      // then rejects the live `JSArray`.
      final dynamic query = _applyPage(queryFn(_select()), limit, offset);
      final dynamic raw = await query;
      final rows = rowsFromWire(raw);
      return List<T>.from(rows);
    } catch (e) {
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
      final dynamic raw = await queryFn(_select()).limit(1).maybeSingle();
      final row = rowFromWire(raw);
      return [if (row != null) row];
    } catch (e) {
      AppLogger.error('Supabase querySingleRow error ($tableName)', e);
      rethrow;
    }
  }

  Future<T> insert(Map<String, dynamic> data) async {
    if (kUseShowcaseData) {
      return Future.value(createRow(ShowcaseCatalog.insert(tableName, data)));
    }
    try {
      final dynamic raw = await SupaFlow.client
          .from(tableName)
          .insert(data)
          .select()
          .limit(1)
          .maybeSingle();
      final row = rowFromWire(raw);
      if (row == null) {
        throw Exception('Failed to insert row into $tableName');
      }
      return row;
    } catch (e) {
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
      final dynamic raw = await update.select();
      return List<T>.from(rowsFromWire(raw));
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
      final dynamic raw = await delete.select();
      return List<T>.from(rowsFromWire(raw));
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
      List<T> read() =>
          ShowcaseCatalog.query(tableName, captured).map(createRow).toList();
      return Stream<List<T>>.multi((controller) {
        controller.add(read());
        final sub = ShowcaseCatalog.changes.listen((_) {
          if (!controller.isClosed) controller.add(read());
        });
        controller
          ..onPause = sub.pause
          ..onResume = sub.resume
          ..onCancel = () => sub.cancel();
      });
    }
    final builder = SupaFlow.client.from(tableName).stream(primaryKey: [primaryKey]);
    final stream = queryFn != null ? queryFn(builder) : builder;
    return stream.map(rowsFromWire);
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
