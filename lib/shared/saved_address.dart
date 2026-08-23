import 'package:degloor_one/backend/supabase/database/tables/addresses_table.dart';

/// Saved customer address. Screens use this instead of [AddressesRow].
class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.userId,
    this.title,
    this.addressText,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String? title;
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime? createdAt;

  factory SavedAddress.fromRow(AddressesRow row) {
    return SavedAddress(
      id: row.id,
      userId: row.userId,
      title: row.title,
      addressText: row.addressText,
      latitude: row.latitude,
      longitude: row.longitude,
      isDefault: row.isDefault,
      createdAt: row.createdAt,
    );
  }
}
