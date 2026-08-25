import 'package:degloor_one/backend/admin_service.dart';
import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/stat_card2/stat_card2_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'admin_control_panel_widget.dart' show AdminControlPanelWidget;
import 'package:flutter/material.dart';

/// Load outcome for the admin desk. The widget only shows these states.
enum AdminDeskStatus {
  loading,
  ready,
  accessDenied,
  signedOut,
  error,
}

class AdminControlPanelModel extends FlutterFlowModel<AdminControlPanelWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for StatCard.
  late StatCard2Model statCardModel1;
  // Model for StatCard.
  late StatCard2Model statCardModel2;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;

  AdminDeskStatus status = AdminDeskStatus.loading;
  String? errorMessage;
  AdminCounts counts = const AdminCounts(pending: 0, verified: 0);
  List<Shop> verificationQueue = const [];
  List<ListingComplaint> pendingComplaints = const [];
  List<ShopCategory> categories = const [];

  bool get isLoading => status == AdminDeskStatus.loading;
  bool get isReady => status == AdminDeskStatus.ready;
  bool get isAccessDenied => status == AdminDeskStatus.accessDenied;
  bool get isSignedOut => status == AdminDeskStatus.signedOut;
  bool get hasError => status == AdminDeskStatus.error;

  @override
  void initState(BuildContext context) {
    statCardModel1 = createModel(context, () => StatCard2Model());
    statCardModel2 = createModel(context, () => StatCard2Model());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  /// Session role is not the gate. The users row is the source of
  /// admin access, so a guest promote still lands on Admin only.
  Future<void> load({
    required String userId,
    VoidCallback? onBusyChanged,
  }) async {
    errorMessage = null;
    if (userId.isEmpty) {
      status = AdminDeskStatus.signedOut;
      onBusyChanged?.call();
      return;
    }
    if (status != AdminDeskStatus.ready) {
      status = AdminDeskStatus.loading;
    }
    onBusyChanged?.call();
    try {
      counts = await AdminService.instance.counts(userId);
      verificationQueue =
          await AdminService.instance.verificationQueue(userId);
      pendingComplaints =
          await AdminService.instance.pendingComplaints(userId);
      categories = await AdminService.instance.businessCategories(userId);
      status = AdminDeskStatus.ready;
    } catch (error) {
      final message = error.toString();
      if (message.contains('Please sign in')) {
        status = AdminDeskStatus.signedOut;
      } else if (message.contains('Admin access required')) {
        status = AdminDeskStatus.accessDenied;
      } else {
        status = AdminDeskStatus.error;
        errorMessage = message;
      }
    } finally {
      onBusyChanged?.call();
    }
  }

  Future<void> verifyBusiness({
    required String userId,
    required String businessId,
    VoidCallback? onBusyChanged,
  }) async {
    await AdminService.instance.verifyBusiness(
      adminUserId: userId,
      businessId: businessId,
    );
    await load(userId: userId, onBusyChanged: onBusyChanged);
  }

  Future<void> resolveComplaint({
    required String userId,
    required String complaintId,
    VoidCallback? onBusyChanged,
  }) async {
    await AdminService.instance.resolveComplaint(
      adminUserId: userId,
      complaintId: complaintId,
    );
    await load(userId: userId, onBusyChanged: onBusyChanged);
  }

  Future<ShopCategory> addCategory({
    required String userId,
    required String name,
    VoidCallback? onBusyChanged,
  }) async {
    final created = await AdminService.instance.addCategory(
      adminUserId: userId,
      name: name,
    );
    await load(userId: userId, onBusyChanged: onBusyChanged);
    return created;
  }

  @override
  void dispose() {
    statCardModel1.dispose();
    statCardModel2.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
  }
}
