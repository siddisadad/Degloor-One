import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/user_profile.dart';

/// Data access for admin queues. Widgets should go through [AdminService].
class AdminRepository {
  Future<UserProfile?> userById(String userId) async {
    if (userId.isEmpty) return null;
    final rows = await UsersTable().queryRows(
      queryFn: (q) => q.eq('id', userId),
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return UserProfile(
      id: row.id,
      email: row.email,
      fullName: row.fullName,
      avatarUrl: row.avatarUrl,
      role: row.role,
      phoneNumber: row.phoneNumber,
      createdAt: row.createdAt,
    );
  }

  Shop _toShop(BusinessesRow row) {
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

  Future<List<Shop>> unverifiedBusinesses() async {
    final rows = await BusinessesTable().queryRows(
      queryFn: (q) =>
          q.eq('is_verified', false).order('created_at', ascending: false),
    );
    return rows.map(_toShop).toList();
  }

  Future<int> businessCount({required bool verified}) async {
    final rows = await BusinessesTable().queryRows(
      queryFn: (q) => q.eq('is_verified', verified),
    );
    return rows.length;
  }

  Future<Shop?> businessById(String businessId) async {
    if (businessId.isEmpty) return null;
    final rows = await BusinessesTable().queryRows(
      queryFn: (q) => q.eq('id', businessId),
      limit: 1,
    );
    return rows.isEmpty ? null : _toShop(rows.first);
  }

  Future<void> verifyBusiness(String businessId) async {
    await BusinessesTable().update(
      data: {'is_verified': true},
      matchingRows: (q) => q.eq('id', businessId),
    );
  }

  Future<List<ComplaintsRow>> pendingComplaints() {
    return ComplaintsTable().queryRows(
      queryFn: (q) =>
          q.eq('status', 'pending').order('created_at', ascending: false),
    );
  }

  Future<ComplaintsRow?> complaintById(String complaintId) async {
    if (complaintId.isEmpty) return null;
    final rows = await ComplaintsTable().queryRows(
      queryFn: (q) => q.eq('id', complaintId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> resolveComplaint(String complaintId) async {
    await ComplaintsTable().update(
      data: {'status': 'resolved'},
      matchingRows: (q) => q.eq('id', complaintId),
    );
  }

  Future<List<BusinessCategoriesRow>> businessCategories() {
    return BusinessCategoriesTable().queryRows(
      queryFn: (q) => q.order('display_order', ascending: true),
    );
  }

  Future<BusinessCategoriesRow> insertBusinessCategory(
    Map<String, dynamic> data,
  ) {
    return BusinessCategoriesTable().insert(data);
  }
}
