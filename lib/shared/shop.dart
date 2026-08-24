import 'dart:convert';

import 'package:degloor_one/shared/shop_hours.dart';

/// Degloor shop listing. Screens use this instead of a table row.
///
/// Listing fields: [id], [name], [categoryId], [subcategory], [addressText],
/// [phoneNumber], [latitude], [longitude], [hours], [photos], [rating],
/// [source], [isVerified], [updatedAt].
class Shop {
  const Shop({
    required this.id,
    required this.name,
    required this.createdAt,
    this.ownerId,
    this.ownerName,
    this.description,
    this.categoryId,
    this.subcategory,
    this.cityId,
    this.addressText,
    this.whatsappNumber,
    this.phoneNumber,
    this.rating,
    this.isOpen,
    this.isVerified,
    this.imageUrl,
    this.photos = const [],
    this.latitude,
    this.longitude,
    this.discoveryRadius,
    this.distanceKm,
    this.source,
    this.updatedAt,
    this.hours = const [],
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final String? ownerId;
  final String? ownerName;
  final String? description;
  final String? categoryId;
  final String? subcategory;
  final String? cityId;
  final String? addressText;
  final String? whatsappNumber;
  final String? phoneNumber;
  final double? rating;
  final bool? isOpen;
  final bool? isVerified;
  final String? imageUrl;
  final List<String> photos;
  final double? latitude;
  final double? longitude;
  final double? discoveryRadius;
  final double? distanceKm;
  final String? source;
  final DateTime? updatedAt;
  final List<ShopHours> hours;

  /// Extra nav payload is already a [Shop].
  factory Shop.fromParam(dynamic value) {
    if (value is Shop) return value;
    throw ArgumentError.value(value, 'value', 'Expected Shop');
  }

  /// Java `BusinessResponse` or a table-shaped map. Accepts listing aliases
  /// (`business_id`, `business_name`, `address`, `phone`, `opening_hours`,
  /// `last_updated`) so screens stay off the wire format.
  factory Shop.fromJson(Map<String, dynamic> json) {
    final photos = _photos(json);
    final imageUrl = _str(json, const ['imageUrl', 'image_url']) ??
        (photos.isEmpty ? null : photos.first);
    final createdAt = _date(json, const ['createdAt', 'created_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return Shop(
      id: _str(json, const ['id', 'businessId', 'business_id']) ?? '',
      name: _str(json, const ['name', 'businessName', 'business_name']) ?? '',
      createdAt: createdAt,
      ownerId: _str(json, const ['ownerId', 'owner_id']),
      ownerName: _str(json, const ['ownerName', 'owner_name']),
      description: _str(json, const ['description']),
      categoryId: _str(json, const ['categoryId', 'category_id']),
      subcategory: _str(json, const ['subcategory', 'subCategory', 'sub_category']),
      cityId: _str(json, const ['cityId', 'city_id']),
      addressText: _str(json, const ['addressText', 'address_text', 'address']),
      whatsappNumber: _str(json, const ['whatsappNumber', 'whatsapp_number']),
      phoneNumber: _str(json, const ['phoneNumber', 'phone_number', 'phone']),
      rating: _num(json, const ['rating']),
      isOpen: _bool(json, const ['open', 'isOpen', 'is_open']),
      isVerified: _bool(json, const ['verified', 'isVerified', 'is_verified']),
      imageUrl: imageUrl,
      photos: photos.isNotEmpty
          ? photos
          : (imageUrl == null || imageUrl.isEmpty ? const [] : [imageUrl]),
      latitude: _num(json, const ['latitude']),
      longitude: _num(json, const ['longitude']),
      discoveryRadius: _num(json, const ['discoveryRadius', 'discovery_radius']),
      distanceKm: _num(json, const ['distanceKm', 'distance_km']),
      source: _str(json, const ['source']),
      updatedAt: _date(json, const [
            'updatedAt',
            'updated_at',
            'lastUpdated',
            'last_updated',
          ]) ??
          createdAt,
      hours: _hours(json),
    );
  }

  static String? _str(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = '$value'.trim();
      if (text.isEmpty || text == 'null') continue;
      return text;
    }
    return null;
  }

  static double? _num(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
    }
    return null;
  }

  static bool? _bool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
    }
    return null;
  }

  static DateTime? _date(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static List<String> _photos(Map<String, dynamic> json) {
    final raw = json['photos'] ?? json['photoUrls'] ?? json['photo_urls'];
    if (raw is List) {
      return [
        for (final item in raw)
          if ('$item'.trim().isNotEmpty) '$item'.trim(),
      ];
    }
    if (raw is String && raw.trim().startsWith('[')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return [
            for (final item in decoded)
              if ('$item'.trim().isNotEmpty) '$item'.trim(),
          ];
        }
      } catch (_) {}
    }
    return const [];
  }

  static List<ShopHours> _hours(Map<String, dynamic> json) {
    final raw = json['hours'] ?? json['openingHours'] ?? json['opening_hours'];
    if (raw is! List) return const [];
    return [
      for (final row in raw.whereType<Map>())
        ShopHours.fromJson({
          ...Map<String, dynamic>.from(row),
          'businessId': row['businessId'] ?? json['id'] ?? json['business_id'],
        }),
    ];
  }
}
