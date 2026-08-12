import '../database.dart';

class DeliveryPartnersTable extends SupabaseTable<DeliveryPartnersRow> {
  @override
  String get tableName => 'delivery_partners';

  @override
  DeliveryPartnersRow createRow(Map<String, dynamic> data) =>
      DeliveryPartnersRow(data);
}

class DeliveryPartnersRow extends SupabaseDataRow {
  DeliveryPartnersRow(super.data);

  @override
  SupabaseTable get table => DeliveryPartnersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get vehicleType => getField<String>('vehicle_type');
  set vehicleType(String? value) => setField<String>('vehicle_type', value);

  String? get vehicleNumber => getField<String>('vehicle_number');
  set vehicleNumber(String? value) => setField<String>('vehicle_number', value);

  bool get isAvailable => getField<bool>('is_available')!;
  set isAvailable(bool value) => setField<bool>('is_available', value);

  bool get isVerified => getField<bool>('is_verified')!;
  set isVerified(bool value) => setField<bool>('is_verified', value);

  double? get currentLatitude => getField<double>('current_latitude');
  set currentLatitude(double? value) =>
      setField<double>('current_latitude', value);

  double? get currentLongitude => getField<double>('current_longitude');
  set currentLongitude(double? value) =>
      setField<double>('current_longitude', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
