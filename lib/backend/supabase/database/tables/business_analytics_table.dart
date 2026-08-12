import '../database.dart';

class BusinessAnalyticsTable extends SupabaseTable<BusinessAnalyticsRow> {
  @override
  String get tableName => 'business_analytics';

  @override
  BusinessAnalyticsRow createRow(Map<String, dynamic> data) => BusinessAnalyticsRow(data);

  Future logEvent({
    required String businessId,
    required String eventType,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    return await insert({
      'business_id': businessId,
      'event_type': eventType,
      if (userId != null && userId.isNotEmpty) 'user_id': userId,
      if (metadata != null) 'metadata': metadata,
    });
  }
}

class BusinessAnalyticsRow extends SupabaseDataRow {
  BusinessAnalyticsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BusinessAnalyticsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get businessId => getField<String>('business_id')!;
  set businessId(String value) => setField<String>('business_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
