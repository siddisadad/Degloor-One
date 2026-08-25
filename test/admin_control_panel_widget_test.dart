import 'package:degloor_one/auth/base_auth_user_provider.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/features/admin/admin_control_panel_model.dart';
import 'package:degloor_one/features/admin/admin_control_panel_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_model.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:degloor_one/shared/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _ShowcaseAdminUser extends BaseAuthUser {
  @override
  bool get loggedIn => true;

  @override
  bool get emailVerified => true;

  @override
  String? get role => 'admin';

  @override
  AuthUserInfo get authUserInfo => const AuthUserInfo(
        uid: ShowcaseCatalog.adminId,
        email: 'admin@degloor.local',
        displayName: 'Sadad Siddi',
      );

  @override
  Future? delete() async {}

  @override
  Future? updateEmail(String email) async {}

  @override
  Future? updatePassword(String newPassword) async {}

  @override
  Future? sendEmailVerification() async {}
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    ShowcaseCatalog.reset();
    currentUser = null;
  });

  testWidgets('admin desk loads the pending cafe on the model', (tester) async {
    late AdminControlPanelModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => AdminControlPanelModel());
        return const SizedBox.shrink();
      }),
    ));

    await model.load(userId: ShowcaseCatalog.adminId);
    expect(model.isReady, isTrue);
    expect(model.isLoading, isFalse);
    expect(model.counts.pending, 1);
    expect(model.counts.verified, greaterThanOrEqualTo(7));
    expect(
      model.verificationQueue.map((row) => row.id),
      contains(ShowcaseCatalog.bizPending),
    );
    expect(model.pendingComplaints.map((row) => row.id), contains('cmp-1'));
    expect(model.categories, isNotEmpty);
  });

  testWidgets('admin desk verifies the pending cafe on the model',
      (tester) async {
    late AdminControlPanelModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => AdminControlPanelModel());
        return const SizedBox.shrink();
      }),
    ));

    await model.verifyBusiness(
      userId: ShowcaseCatalog.adminId,
      businessId: ShowcaseCatalog.bizPending,
    );
    expect(model.isReady, isTrue);
    expect(model.verificationQueue, isEmpty);
    expect(model.counts.pending, 0);
  });

  testWidgets('admin desk resolves a pending complaint on the model',
      (tester) async {
    late AdminControlPanelModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => AdminControlPanelModel());
        return const SizedBox.shrink();
      }),
    ));

    await model.resolveComplaint(
      userId: ShowcaseCatalog.adminId,
      complaintId: 'cmp-1',
    );
    expect(model.isReady, isTrue);
    expect(model.pendingComplaints, isEmpty);
  });

  testWidgets('signed-out admin desk asks to sign in', (tester) async {
    late AdminControlPanelModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => AdminControlPanelModel());
        return const SizedBox.shrink();
      }),
    ));

    await model.load(userId: '');
    expect(model.isSignedOut, isTrue);
    expect(model.isLoading, isFalse);
    expect(model.isReady, isFalse);
  });

  testWidgets('guest cannot open the admin desk even after a local promote',
      (tester) async {
    installGuestSession();
    promoteGuestRole(UserRole.admin);
    late AdminControlPanelModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => AdminControlPanelModel());
        return const SizedBox.shrink();
      }),
    ));

    await model.load(userId: currentUserUid);
    expect(currentUserUid, GuestAuthUser.guestUid);
    expect(currentUser?.role, 'admin');
    expect(model.isAccessDenied, isTrue);
    expect(model.isLoading, isFalse);
    expect(model.verificationQueue, isEmpty);
  });

  testWidgets('admin desk shows the pending cafe, not an empty queue',
      (tester) async {
    currentUser = _ShowcaseAdminUser();
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: AdminControlPanelWidget()),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Admin only'), findsNothing);
    expect(find.text('Please sign in'), findsNothing);
    expect(find.text('Queue is clear'), findsNothing);
    expect(find.text('Admin Control'), findsOneWidget);
    expect(find.text('New Corner Cafe'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);

    await tester.tap(find.text('Complaints'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Missing sweet in thali'), findsOneWidget);
    expect(find.text('No pending complaints'), findsNothing);

    await tester.tap(find.text('System'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Grocery'), findsOneWidget);
  });

  testWidgets('guest admin route shows Admin only, not a spinner',
      (tester) async {
    installGuestSession();
    await tester.pumpWidget(
      const MaterialApp(home: AdminControlPanelWidget()),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Admin only'), findsOneWidget);
    expect(find.text('Queue is clear'), findsNothing);
  });

  testWidgets('logged-out admin route asks to sign in, not a spinner',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AdminControlPanelWidget()),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Please sign in'), findsOneWidget);
    expect(find.text('Admin only'), findsNothing);
  });
}
