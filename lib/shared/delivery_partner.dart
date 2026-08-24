import 'package:degloor_one/backend/supabase/database/tables/delivery_partners_table.dart';

/// Degloor rider. Screens use this instead of [DeliveryPartnersRow].
class DeliveryPartner {
  const DeliveryPartner({
    required this.id,
    required this.userId,
    required this.isAvailable,
    required this.isVerified,
    required this.createdAt,
    this.vehicleType,
    this.vehicleNumber,
    this.currentLatitude,
    this.currentLongitude,
  });

  final String id;
  final String userId;
  final bool isAvailable;
  final bool isVerified;
  final DateTime createdAt;
  final String? vehicleType;
  final String? vehicleNumber;
  final double? currentLatitude;
  final double? currentLongitude;

  factory DeliveryPartner.fromRow(DeliveryPartnersRow row) {
    return DeliveryPartner(
      id: row.id,
      userId: row.userId,
      isAvailable: row.isAvailable,
      isVerified: row.isVerified,
      createdAt: row.createdAt,
      vehicleType: row.vehicleType,
      vehicleNumber: row.vehicleNumber,
      currentLatitude: row.currentLatitude,
      currentLongitude: row.currentLongitude,
    );
  }

  factory DeliveryPartner.fromJson(Map<String, dynamic> json) {
    return DeliveryPartner(
      id: '${json['id'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      isAvailable:
          json['available'] as bool? ?? json['isAvailable'] as bool? ?? false,
      isVerified:
          json['verified'] as bool? ?? json['isVerified'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      vehicleType: json['vehicleType'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
      currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
      currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
    );
  }
}
