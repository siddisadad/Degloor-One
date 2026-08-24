import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/app_notification.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('inbox pages stay scoped to the signed-in user', () async {
    expect(kUseShowcaseData, isTrue);
    final page = await NotificationService.instance.listForUser(
      GuestAuthUser.guestUid,
      page: const PageQuery(limit: 1),
    );
    expect(page.items, hasLength(1));
    expect(page.hasMore, isTrue);
    expect(page.items, everyElement(isA<AppNotification>()));
    expect(page.items, isNot(anyElement(isA<NotificationsRow>())));
    expect(
      page.items.every((row) => row.userId == GuestAuthUser.guestUid),
      isTrue,
    );
  });

  test('unread count does not require the full inbox', () async {
    expect(
      await NotificationService.instance.unreadCount(GuestAuthUser.guestUid),
      1,
    );
    await NotificationService.instance.markRead(
      notificationId: 'nt-1',
      userId: GuestAuthUser.guestUid,
    );
    expect(
      await NotificationService.instance.unreadCount(GuestAuthUser.guestUid),
      0,
    );
  });

  test('another user cannot mark the guest notice read', () async {
    await NotificationService.instance.markRead(
      notificationId: 'nt-1',
      userId: ShowcaseCatalog.customer2,
    );
    expect(
      await NotificationService.instance.unreadCount(GuestAuthUser.guestUid),
      1,
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

  test('Java notification JSON maps to AppNotification', () {
    final notice = AppNotification.fromJson({
      'id': 'nt-1',
      'title': 'Order Updated',
      'message': 'Your order #order-ou is now out_for_delivery.',
      'type': 'order_status',
      'read': false,
      'createdAt': '2026-08-24T10:00:00Z',
    }, userId: GuestAuthUser.guestUid);
    expect(notice, isA<AppNotification>());
    expect(notice.id, 'nt-1');
    expect(notice.userId, GuestAuthUser.guestUid);
    expect(notice.title, 'Order Updated');
    expect(notice.isRead, isFalse);
    expect(notice.type, 'order_status');
    expect(notice.createdAt.toUtc().year, 2026);

    final read = AppNotification.fromJson({
      'id': 'nt-2',
      'title': 'Read',
      'message': 'Already seen.',
      'isRead': true,
    }, userId: GuestAuthUser.guestUid);
    expect(read.isRead, isTrue);
    expect(read.createdAt.millisecondsSinceEpoch, 0);
  });
}
