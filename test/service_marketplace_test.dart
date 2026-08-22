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
