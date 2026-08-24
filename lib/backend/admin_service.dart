import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/backend/repositories/admin_repository.dart';
import 'package:degloor_one/backend/supabase/database/tables/business_categories_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/complaints_table.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'package:degloor_one/shared/user_profile.dart';

class AdminCounts {
  const AdminCounts({required this.pending, required this.verified});

  final int pending;
  final int verified;
}

class AdminService {
  AdminService({AdminRepository? repository})
      : _repository = repository ?? AdminRepository();

  final AdminRepository _repository;

  static final instance = AdminService();

  static const _signInMessage = 'Please sign in to continue';
  static const _adminMessage = 'Admin access required';

  Future<UserProfile> requireAdmin(String userId) async {
    if (userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    final user = await _repository.userById(userId);
    if (user == null || user.role != 'admin') {
      throw Exception(_adminMessage);
    }
    return user;
  }

  Future<AdminCounts> counts(String adminUserId) async {
    await requireAdmin(adminUserId);
    final pending = await _repository.businessCount(verified: false);
    final verified = await _repository.businessCount(verified: true);
    return AdminCounts(pending: pending, verified: verified);
  }

  Future<List<Shop>> verificationQueue(String adminUserId) async {
    await requireAdmin(adminUserId);
    return _repository.unverifiedBusinesses();
  }

  Future<void> verifyBusiness({
    required String adminUserId,
    required String businessId,
  }) async {
    await requireAdmin(adminUserId);
    final shop = await _repository.businessById(businessId);
    if (shop == null) {
      throw Exception('Business not found');
    }
    if (shop.isVerified == true) return;
    await _repository.verifyBusiness(businessId);
    final ownerId = shop.ownerId;
    if (ownerId == null || ownerId.isEmpty) return;
    await NotificationService.adminNotify(
      userId: ownerId,
      title: 'Business Verified!',
      message:
          'Your business "${shop.name}" has been verified and is now live.',
      type: 'business_verified',
    );
  }

  Future<List<ListingComplaint>> pendingComplaints(String adminUserId) async {
    await requireAdmin(adminUserId);
    final rows = await _repository.pendingComplaints();
    return rows.map(_complaintFromRow).toList();
  }

  Future<void> resolveComplaint({
    required String adminUserId,
    required String complaintId,
  }) async {
    await requireAdmin(adminUserId);
    final complaint = await _repository.complaintById(complaintId);
    if (complaint == null) {
      throw Exception('Complaint not found');
    }
    await _repository.resolveComplaint(complaintId);
    await NotificationService.adminNotify(
      userId: complaint.userId,
      title: 'Complaint Resolved',
      message:
          'Your complaint regarding "${complaint.subject}" has been resolved.',
      type: 'complaint_resolved',
    );
  }

  Future<List<ShopCategory>> businessCategories(String adminUserId) async {
    await requireAdmin(adminUserId);
    final rows = await _repository.businessCategories();
    return rows.map(_categoryFromRow).toList();
  }

  Future<ShopCategory> addCategory({
    required String adminUserId,
    required String name,
  }) async {
    await requireAdmin(adminUserId);
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw Exception('Please enter a category name');
    }
    final existing = await _repository.businessCategories();
    for (final category in existing) {
      if (category.name.toLowerCase() == trimmed.toLowerCase()) {
        throw Exception('That category already exists');
      }
    }
    var nextOrder = 1;
    for (final category in existing) {
      final order = category.displayOrder ?? 0;
      if (order >= nextOrder) nextOrder = order + 1;
    }
    final row = await _repository.insertBusinessCategory({
      'name': trimmed,
      'icon_name': 'category_rounded',
      'display_order': nextOrder,
    });
    return _categoryFromRow(row);
  }
}

ListingComplaint _complaintFromRow(ComplaintsRow row) {
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

ShopCategory _categoryFromRow(BusinessCategoriesRow row) {
  return ShopCategory(
    id: row.id,
    name: row.name,
    iconName: row.iconName,
    displayOrder: row.displayOrder,
    createdAt: row.createdAt,
  );
}
