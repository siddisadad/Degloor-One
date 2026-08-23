import 'package:degloor_one/backend/supabase/database/tables/businesses_table.dart';

/// Degloor shop. Screens use this instead of [BusinessesRow].
class Shop {
  const Shop({
    required this.id,
    required this.name,
    required this.createdAt,
    this.ownerId,
    this.ownerName,
    this.description,
    this.categoryId,
    this.cityId,
    this.addressText,
    this.whatsappNumber,
    this.phoneNumber,
    this.rating,
    this.isOpen,
    this.isVerified,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.discoveryRadius,
    this.distanceKm,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final String? ownerId;
  final String? ownerName;
  final String? description;
  final String? categoryId;
  final String? cityId;
  final String? addressText;
  final String? whatsappNumber;
  final String? phoneNumber;
  final double? rating;
  final bool? isOpen;
  final bool? isVerified;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final double? discoveryRadius;
  final double? distanceKm;

  factory Shop.fromRow(BusinessesRow row) {
    return Shop(
      id: row.id,
      name: row.name,
      createdAt: row.createdAt,
      ownerId: row.ownerId,
      ownerName: row.ownerName,
      description: row.description,
      categoryId: row.categoryId,
      cityId: row.cityId,
      addressText: row.addressText,
      whatsappNumber: row.whatsappNumber,
      phoneNumber: row.phoneNumber,
      rating: row.rating,
      isOpen: row.isOpen,
      isVerified: row.isVerified,
      imageUrl: row.imageUrl,
      latitude: row.latitude,
      longitude: row.longitude,
      discoveryRadius: row.discoveryRadius,
      distanceKm: row.distanceKm,
    );
  }

  /// Extra nav payload is already a [Shop]; serialized routes still send a row.
  factory Shop.fromParam(dynamic value) {
    if (value is Shop) return value;
    if (value is BusinessesRow) return Shop.fromRow(value);
    throw ArgumentError.value(value, 'value', 'Expected Shop or BusinessesRow');
  }
}
