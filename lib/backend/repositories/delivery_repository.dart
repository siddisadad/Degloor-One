import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/data/datasources/supabase_delivery_maps.dart';
import 'package:degloor_one/shared/delivery_assignment.dart';
import 'package:degloor_one/shared/delivery_partner.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/page_query.dart';

/// Table access for riders. Domain mapping lives on [SupabaseDeliveryRepository].
class DeliveryRepository {
  Future<DeliveryPartner?> partnerForUser(String userId) async {
    if (userId.isEmpty) return null;
    final rows = await DeliveryPartnersTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId),
      limit: 1,
    );
    return rows.isEmpty ? null : deliveryPartnerFromRow(rows.first);
  }

  Future<DeliveryPartner> registerPartner(String userId) async {
    final row = await DeliveryPartnersTable().insert({
      'user_id': userId,
      'is_available': false,
      'is_verified': false,
    });
    return deliveryPartnerFromRow(row);
  }

  Future<void> setAvailability({
    required String partnerId,
    required bool available,
  }) async {
    if (partnerId.isEmpty) return;
    await DeliveryPartnersTable().update(
      data: {'is_available': available},
      matchingRows: (src) => src.eq('id', partnerId),
    );
  }

  Future<DeliveryAssignment?> activeForPartner(String partnerId) async {
    if (partnerId.isEmpty) return null;
    final rows = await DeliveryAssignmentsTable().queryRows(
      queryFn: (q) =>
          q.eq('delivery_partner_id', partnerId).neq('status', 'delivered'),
      limit: 1,
    );
    return rows.isEmpty ? null : deliveryAssignmentFromRow(rows.first);
  }

  Future<List<OrdersRow>> readyOrders({
    PageQuery page = const PageQuery(),
  }) {
    return OrdersTable().queryRows(
      queryFn: (q) => q
          .eq('status', OrderLifecycle.ready)
          .order('created_at', ascending: false),
      limit: page.limit,
      offset: page.offset,
    );
  }

  Future<DeliveryAssignment?> activeAssignment(String orderId) async {
    if (orderId.isEmpty) return null;
    final rows = await DeliveryAssignmentsTable().queryRows(
      queryFn: (q) => q.eq('order_id', orderId).neq('status', 'delivered'),
      limit: 1,
    );
    return rows.isEmpty ? null : deliveryAssignmentFromRow(rows.first);
  }

  Stream<List<DeliveryPartner>> watchPartner(String partnerId) {
    return DeliveryPartnersTable()
        .stream(
          primaryKey: 'id',
          queryFn: (q) => q.eq('id', partnerId),
        )
        .map((rows) => rows.map(deliveryPartnerFromRow).toList());
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? partnerId,
    String? userId,
  }) {
    return DeliveryPartnersTable().update(
      data: {
        'current_latitude': latitude,
        'current_longitude': longitude,
      },
      matchingRows: (q) {
        if (partnerId != null && partnerId.isNotEmpty) {
          return q.eq('id', partnerId);
        }
        return q.eq('user_id', userId);
      },
    );
  }
}
