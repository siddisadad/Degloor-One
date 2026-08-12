import '../database.dart';

class JobsTable extends SupabaseTable<JobsRow> {
  @override
  String get tableName => 'jobs';

  @override
  JobsRow createRow(Map<String, dynamic> data) => JobsRow(data);
}

class JobsRow extends SupabaseDataRow {
  JobsRow(super.data);

  @override
  SupabaseTable get table => JobsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get businessId => getField<String>('business_id');
  set businessId(String? value) => setField<String>('business_id', value);

  String? get posterId => getField<String>('poster_id');
  set posterId(String? value) => setField<String>('poster_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  String get jobType => getField<String>('job_type')!;
  set jobType(String value) => setField<String>('job_type', value);

  String? get salaryRange => getField<String>('salary_range');
  set salaryRange(String? value) => setField<String>('salary_range', value);

  String? get locationText => getField<String>('location_text');
  set locationText(String? value) => setField<String>('location_text', value);

  bool get isActive => getField<bool>('is_active', true)!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
