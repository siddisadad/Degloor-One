import 'database.dart';
import 'package:degloor_one/core/error_handler.dart';

abstract class SupabaseTable<T extends SupabaseDataRow> {
  String get tableName;
  T createRow(Map<String, dynamic> data);

  PostgrestFilterBuilder _select() => SupaFlow.client.from(tableName).select();

  Future<List<T>> queryRows({
    required PostgrestTransformBuilder Function(PostgrestFilterBuilder) queryFn,
    int? limit,
  }) async {
    if (kUsesDeadFlutterFlowHost) return [];
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
    required PostgrestTransformBuilder Function(PostgrestFilterBuilder) queryFn,
  }) async {
    if (kUsesDeadFlutterFlowHost) return [];
    try {
      final r = await queryFn(_select()).limit(1).select().maybeSingle();
      return [if (r != null) createRow(r)];
    } catch (e) {
      AppLogger.error('Supabase querySingleRow error ($tableName)', e);
      rethrow;
    }
  }

  Future<T> insert(Map<String, dynamic> data) {
    if (kUsesDeadFlutterFlowHost) {
      return Future.error(Exception('Failed to fetch'));
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
    required PostgrestTransformBuilder Function(PostgrestFilterBuilder)
        matchingRows,
    bool returnRows = false,
  }) async {
    if (kUsesDeadFlutterFlowHost) {
      throw Exception('Failed to fetch');
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
    required PostgrestTransformBuilder Function(PostgrestFilterBuilder)
        matchingRows,
    bool returnRows = false,
  }) async {
    if (kUsesDeadFlutterFlowHost) {
      throw Exception('Failed to fetch');
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
    if (kUsesDeadFlutterFlowHost) {
      throw Exception('Failed to fetch');
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
    SupabaseStreamBuilder Function(SupabaseStreamFilterBuilder)? queryFn,
  }) {
    if (kUsesDeadFlutterFlowHost) {
      return Stream<List<T>>.value(<T>[]);
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
