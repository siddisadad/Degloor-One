import 'package:degloor_one/backend/supabase/database/tables/delivery_assignments_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/delivery_partners_table.dart';
import 'package:degloor_one/shared/delivery_assignment.dart';
import 'package:degloor_one/shared/delivery_partner.dart';

DeliveryPartner deliveryPartnerFromRow(DeliveryPartnersRow row) {
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

DeliveryAssignment deliveryAssignmentFromRow(DeliveryAssignmentsRow row) {
  return DeliveryAssignment(
    id: row.id,
    orderId: row.orderId,
    deliveryPartnerId: row.deliveryPartnerId,
    status: row.status,
    createdAt: row.createdAt,
  );
}
