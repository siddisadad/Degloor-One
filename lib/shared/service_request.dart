import 'package:degloor_one/backend/supabase/database/tables/service_requests_table.dart';

/// Booking between a customer and a provider. Screens use this instead of
/// [ServiceRequestsRow].
class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.createdAt,
    this.userId,
    this.providerId,
    this.description,
    this.status,
    this.scheduledAt,
  });

  final String id;
  final DateTime createdAt;
  final String? userId;
  final String? providerId;
  final String? description;
  final String? status;
  final DateTime? scheduledAt;

  factory ServiceRequest.fromRow(ServiceRequestsRow row) {
    return ServiceRequest(
      id: row.id,
      createdAt: row.createdAt,
      userId: row.userId,
      providerId: row.providerId,
      description: row.description,
      status: row.status,
      scheduledAt: row.scheduledAt,
    );
  }
}
