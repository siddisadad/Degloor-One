import '../database.dart';

class BusinessHoursTable extends SupabaseTable<BusinessHoursRow> {
  @override
  String get tableName => 'business_hours';

  @override
  BusinessHoursRow createRow(Map<String, dynamic> data) => BusinessHoursRow(data);
}

class BusinessHoursRow extends SupabaseDataRow {
  BusinessHoursRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BusinessHoursTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get businessId => getField<String>('business_id');
  set businessId(String? value) => setField<String>('business_id', value);

  int get dayOfWeek => getField<int>('day_of_week')!;
  set dayOfWeek(int value) => setField<int>('day_of_week', value);

  PostgresTime? get openTime => getField<PostgresTime>('open_time');
  set openTime(PostgresTime? value) => setField<PostgresTime>('open_time', value);

  PostgresTime? get closeTime => getField<PostgresTime>('close_time');
  set closeTime(PostgresTime? value) => setField<PostgresTime>('close_time', value);

  bool get isClosed => getField<bool>('is_closed') ?? false;
  set isClosed(bool value) => setField<bool>('is_closed', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
