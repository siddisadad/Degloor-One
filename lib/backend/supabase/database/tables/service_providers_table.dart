import '../database.dart';

class ServiceProvidersTable extends SupabaseTable<ServiceProvidersRow> {
  @override
  String get tableName => 'service_providers';

  @override
  ServiceProvidersRow createRow(Map<String, dynamic> data) =>
      ServiceProvidersRow(data);
}

class ServiceProvidersRow extends SupabaseDataRow {
  ServiceProvidersRow(super.data);

  @override
  SupabaseTable get table => ServiceProvidersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get categoryId => getField<String>('category_id');
  set categoryId(String? value) => setField<String>('category_id', value);

  String? get bio => getField<String>('bio');
  set bio(String? value) => setField<String>('bio', value);

  double? get hourlyRate => getField<double>('hourly_rate');
  set hourlyRate(double? value) => setField<double>('hourly_rate', value);

  int? get experienceYears => getField<int>('experience_years');
  set experienceYears(int? value) => setField<int>('experience_years', value);

  bool get isVerified => getField<bool>('is_verified') ?? false;
  set isVerified(bool value) => setField<bool>('is_verified', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
