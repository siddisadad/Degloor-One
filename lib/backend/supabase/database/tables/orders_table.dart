import '../database.dart';

class OrdersTable extends SupabaseTable<OrdersRow> {
  @override
  String get tableName => 'orders';

  @override
  OrdersRow createRow(Map<String, dynamic> data) => OrdersRow(data);
}

class OrdersRow extends SupabaseDataRow {
  OrdersRow(super.data);

  @override
  SupabaseTable get table => OrdersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get businessId => getField<String>('business_id')!;
  set businessId(String value) => setField<String>('business_id', value);

  double get totalAmount => getField<double>('total_amount')!;
  set totalAmount(double value) => setField<double>('total_amount', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get paymentStatus => getField<String>('payment_status')!;
  set paymentStatus(String value) => setField<String>('payment_status', value);

  String? get deliveryAddressId => getField<String>('delivery_address_id');
  set deliveryAddressId(String? value) => setField<String>('delivery_address_id', value);

  double? get deliveryFee => getField<double>('delivery_fee');
  set deliveryFee(double? value) => setField<double>('delivery_fee', value);

  String? get paymentMethod => getField<String>('payment_method');
  set paymentMethod(String? value) => setField<String>('payment_method', value);

  String? get deliveryOtp => getField<String>('delivery_otp');
  set deliveryOtp(String? value) => setField<String>('delivery_otp', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
