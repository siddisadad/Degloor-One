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
}
