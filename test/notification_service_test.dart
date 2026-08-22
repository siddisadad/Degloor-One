import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
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
}
