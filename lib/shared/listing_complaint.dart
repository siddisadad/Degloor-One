import 'package:degloor_one/backend/supabase/database/tables/complaints_table.dart';

/// Customer report about a listing. Screens use this instead of
/// [ComplaintsRow].
class ListingComplaint {
  const ListingComplaint({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    this.orderId,
    this.businessId,
  });

  final String id;
  final String userId;
  final String subject;
  final String description;
  final String status;
  final DateTime createdAt;
  final String? orderId;
  final String? businessId;

  factory ListingComplaint.fromRow(ComplaintsRow row) {
    return ListingComplaint(
      id: row.id,
      userId: row.userId,
      subject: row.subject,
      description: row.description,
      status: row.status,
      createdAt: row.createdAt,
      orderId: row.orderId,
      businessId: row.businessId,
    );
  }
}
