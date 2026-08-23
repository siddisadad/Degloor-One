import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/admin_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('guest cannot open admin queues', () async {
    await expectLater(
      AdminService.instance.verificationQueue(GuestAuthUser.guestUid),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Admin access required'),
        ),
      ),
    );
  });

  test('admin can verify the pending cafe', () async {
    final counts =
        await AdminService.instance.counts(ShowcaseCatalog.adminId);
    expect(counts.pending, 1);
    expect(counts.verified, greaterThanOrEqualTo(7));

    final queue =
        await AdminService.instance.verificationQueue(ShowcaseCatalog.adminId);
    expect(queue, everyElement(isA<Shop>()));
    expect(queue, isNot(anyElement(isA<BusinessesRow>())));
    expect(queue.map((row) => row.id), contains(ShowcaseCatalog.bizPending));

    await AdminService.instance.verifyBusiness(
      adminUserId: ShowcaseCatalog.adminId,
      businessId: ShowcaseCatalog.bizPending,
    );
    final after =
        await AdminService.instance.verificationQueue(ShowcaseCatalog.adminId);
    expect(after, isEmpty);

    final notices = ShowcaseCatalog.query(
      'notifications',
      ShowcaseQuery()..eq('user_id', ShowcaseCatalog.owner5),
    );
    expect(
      notices.any((row) => '${row['type']}' == 'business_verified'),
      isTrue,
    );
  });

  test('admin can resolve a pending complaint', () async {
    final pending = await AdminService.instance
        .pendingComplaints(ShowcaseCatalog.adminId);
    expect(pending.map((row) => row.id), contains('cmp-1'));

    await AdminService.instance.resolveComplaint(
      adminUserId: ShowcaseCatalog.adminId,
      complaintId: 'cmp-1',
    );
    expect(
      await AdminService.instance.pendingComplaints(ShowcaseCatalog.adminId),
      isEmpty,
    );
  });

  test('admin can add a unique business category', () async {
    final created = await AdminService.instance.addCategory(
      adminUserId: ShowcaseCatalog.adminId,
      name: 'Stationery',
    );
    expect(created.name, 'Stationery');
    expect(created.displayOrder, greaterThan(7));

    await expectLater(
      AdminService.instance.addCategory(
        adminUserId: ShowcaseCatalog.adminId,
        name: 'grocery',
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('already exists'),
        ),
      ),
    );
  });
}
