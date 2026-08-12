import '../database.dart';

class ServiceRequestsTable extends SupabaseTable<ServiceRequestsRow> {
  @override
  String get tableName => 'service_requests';

  @override
  ServiceRequestsRow createRow(Map<String, dynamic> data) =>
      ServiceRequestsRow(data);
}

class ServiceRequestsRow extends SupabaseDataRow {
  ServiceRequestsRow(super.data);

  @override
  SupabaseTable get table => ServiceRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get providerId => getField<String>('provider_id');
  set providerId(String? value) => setField<String>('provider_id', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get scheduledAt => getField<DateTime>('scheduled_at');
  set scheduledAt(DateTime? value) => setField<DateTime>('scheduled_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
