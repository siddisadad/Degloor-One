/// Degloor shop. Screens use this instead of a table row.
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

  /// Extra nav payload is already a [Shop].
  factory Shop.fromParam(dynamic value) {
    if (value is Shop) return value;
    throw ArgumentError.value(value, 'value', 'Expected Shop');
  }
}
