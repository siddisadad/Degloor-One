import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('inbox lists the guest notifications newest first', () async {
    expect(kUseShowcaseData, isTrue);
    final page = await NotificationService.instance.listForUser(
      GuestAuthUser.guestUid,
      page: const PageQuery(limit: 20),
    );
    expect(page.items, isNotEmpty);
    expect(page.items.first.userId, GuestAuthUser.guestUid);
    expect(
      page.items.first.createdAt.isAfter(page.items.last.createdAt) ||
          page.items.length == 1,
      isTrue,
    );
  });

  test('inbox paginates and reports unread count', () async {
    final first = await NotificationService.instance.listForUser(
      GuestAuthUser.guestUid,
      page: const PageQuery(limit: 1),
    );
    expect(first.items, hasLength(1));
    expect(first.hasMore, isTrue);

    final unread =
        await NotificationService.instance.unreadCount(GuestAuthUser.guestUid);
    expect(unread, greaterThan(0));
  });

  test('mark read and mark all read update the showcase inbox', () async {
    final page = await NotificationService.instance.listForUser(
      GuestAuthUser.guestUid,
    );
    final unread = page.items.firstWhere((row) => !row.isRead);
    await NotificationService.instance.markRead(
      notificationId: unread.id,
      userId: GuestAuthUser.guestUid,
    );
    final after = ShowcaseCatalog.query(
      'notifications',
      ShowcaseQuery()..eq('id', unread.id),
    );
    expect(after.single['is_read'], isTrue);

    await NotificationService.instance.markAllRead(GuestAuthUser.guestUid);
    expect(
      await NotificationService.instance.unreadCount(GuestAuthUser.guestUid),
      0,
    );
  });

  test('admin notify writes a showcase notification', () async {
    await NotificationService.adminNotify(
      userId: GuestAuthUser.guestUid,
      title: 'Business Verified!',
      message: 'Your shop is live.',
      type: 'business_verified',
    );
    final rows = ShowcaseCatalog.query(
      'notifications',
      ShowcaseQuery()
        ..eq('user_id', GuestAuthUser.guestUid)
        ..eq('type', 'business_verified'),
    );
    expect(rows, isNotEmpty);
    expect(rows.last['title'], 'Business Verified!');
  });

  test('clear all removes the guest inbox', () async {
    await NotificationService.instance.clearAll(GuestAuthUser.guestUid);
    final page = await NotificationService.instance.listForUser(
      GuestAuthUser.guestUid,
    );
    expect(page.items, isEmpty);
  });
}
