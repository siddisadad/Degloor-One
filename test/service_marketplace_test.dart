import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('providers paginate and filter by category', () async {
    expect(kUseShowcaseData, isTrue);
    final first = await ServiceMarketplaceService.instance.providers(
      page: const PageQuery(limit: 1),
    );
    expect(first.items, hasLength(1));
    expect(first.hasMore, isTrue);
    expect(first.items.first['users']['full_name'], isNotEmpty);

    final electricians = await ServiceMarketplaceService.instance.providers(
      categoryId: 'scat-electric',
    );
    expect(electricians.items, isNotEmpty);
    expect(
      electricians.items.every((row) => row['category_id'] == 'scat-electric'),
      isTrue,
    );
  });

  test('customers can request a service and providers can accept it', () async {
    final request = await ServiceMarketplaceService.instance.createRequest(
      userId: GuestAuthUser.guestUid,
      providerId: 'sp-ravi',
      description: 'Fix the kitchen tube light.',
      scheduledAt: DateTime.now().add(const Duration(days: 1)),
    );
    expect(request.status, 'pending');
    expect(request.providerId, 'sp-ravi');

    final notices = ShowcaseCatalog.query(
      'notifications',
      ShowcaseQuery()
        ..eq('user_id', 'user-electrician')
        ..eq('type', 'service_request'),
    );
    expect(notices, isNotEmpty);

    await ServiceMarketplaceService.instance.updateStatus(
      requestId: request.id,
      nextStatus: 'accepted',
      actorUserId: 'user-electrician',
    );
    final updated = ShowcaseCatalog.query(
      'service_requests',
      ShowcaseQuery()..eq('id', request.id),
    );
    expect(updated.single['status'], 'accepted');

    await expectLater(
      ServiceMarketplaceService.instance.updateStatus(
        requestId: request.id,
        nextStatus: 'declined',
        actorUserId: 'user-electrician',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('provider profile lookup joins user and category', () async {
    final provider =
        await ServiceMarketplaceService.instance.providerById('sp-ravi');
    expect(provider, isNotNull);
    expect(provider!['users']['full_name'], isNotEmpty);
    expect(provider['service_categories']['name'], 'Electrician');
  });

  test('guest can register as a provider once', () async {
    final profile = await ServiceMarketplaceService.instance.register(
      userId: GuestAuthUser.guestUid,
      categoryId: 'scat-electric',
      experienceYears: '5',
      hourlyRate: '200',
      bio: 'Fan and wiring repair in Degloor.',
    );
    expect(profile.userId, GuestAuthUser.guestUid);
    expect(profile.categoryId, 'scat-electric');
    expect(profile.experienceYears, 5);
    expect(profile.hourlyRate, 200);
    expect(profile.isVerified, isFalse);

    await expectLater(
      ServiceMarketplaceService.instance.register(
        userId: GuestAuthUser.guestUid,
        categoryId: 'scat-plumb',
        experienceYears: '2',
        hourlyRate: '150',
        bio: 'Second profile',
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('already'),
        ),
      ),
    );
  });

  test('register rejects a missing category or signed-out user', () async {
    await expectLater(
      ServiceMarketplaceService.instance.register(
        userId: '',
        categoryId: 'scat-electric',
        experienceYears: '1',
        hourlyRate: '100',
        bio: 'Wiring',
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('sign in'),
        ),
      ),
    );

    await expectLater(
      ServiceMarketplaceService.instance.register(
        userId: GuestAuthUser.guestUid,
        categoryId: 'missing-category',
        experienceYears: '1',
        hourlyRate: '100',
        bio: 'Wiring',
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('category'),
        ),
      ),
    );
  });

  test('requestActions only allow pending accept/decline and accepted complete',
      () {
    final pending =
        ServiceMarketplaceService.instance.requestActions('pending');
    expect(pending.canAccept, isTrue);
    expect(pending.canDecline, isTrue);
    expect(pending.canComplete, isFalse);

    final accepted =
        ServiceMarketplaceService.instance.requestActions('accepted');
    expect(accepted.canAccept, isFalse);
    expect(accepted.canComplete, isTrue);

    final done =
        ServiceMarketplaceService.instance.requestActions('completed');
    expect(done.canAccept, isFalse);
    expect(done.canComplete, isFalse);
  });

  test('seeded pending request can be accepted by the provider', () async {
    await ServiceMarketplaceService.instance.updateStatus(
      requestId: 'sr-1',
      nextStatus: 'accepted',
      actorUserId: 'user-electrician',
    );
    final rows = ShowcaseCatalog.query(
      'service_requests',
      ShowcaseQuery()..eq('id', 'sr-1'),
    );
    expect(rows.single['status'], 'accepted');
  });
}
