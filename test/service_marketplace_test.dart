import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/service_category.dart';
import 'package:degloor_one/shared/service_provider_profile.dart';
import 'package:degloor_one/shared/service_request.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const nativeChannel = MethodChannel('com.deshmukh.degloorone/services');

  setUp(ShowcaseCatalog.reset);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nativeChannel, null);
  });

  test('showcase categories and providers skip the native channel', () async {
    var invoked = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nativeChannel, (call) async {
      invoked += 1;
      return const [];
    });

    expect(kUseShowcaseData, isTrue);
    final categories = await ServiceMarketplaceService.instance.categories();
    final providers = await ServiceMarketplaceService.instance.providers(
      page: const PageQuery(limit: 2),
    );

    expect(invoked, 0);
    expect(categories, isNotEmpty);
    expect(providers.items, isNotEmpty);
  });

  test('service categories use the domain type', () async {
    final categories = await ServiceMarketplaceService.instance.categories();
    expect(categories, isNotEmpty);
    expect(categories, everyElement(isA<ServiceCategory>()));
    expect(categories, isNot(anyElement(isA<ServiceCategoriesRow>())));
    expect(categories.map((row) => row.id), contains('scat-electric'));
  });

  test('providers paginate and filter by category', () async {
    expect(kUseShowcaseData, isTrue);
    final first = await ServiceMarketplaceService.instance.providers(
      page: const PageQuery(limit: 1),
    );
    expect(first.items, hasLength(1));
    expect(first.hasMore, isTrue);
    expect(first.items.first.user?.fullName, isNotEmpty);

    final electricians = await ServiceMarketplaceService.instance.providers(
      categoryId: 'scat-electric',
    );
    expect(electricians.items, isNotEmpty);
    expect(
      electricians.items.every((row) => row.categoryId == 'scat-electric'),
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
    expect(request, isA<ServiceRequest>());
    expect(request, isNot(isA<ServiceRequestsRow>()));
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

  test('customers can watch their own service requests', () async {
    final userId = GuestAuthUser.guestUid;
    await ServiceMarketplaceService.instance.createRequest(
      userId: userId,
      providerId: 'sp-ravi',
      description: 'Request 1',
      scheduledAt: DateTime.now(),
    );

    final stream = ServiceMarketplaceService.instance.watchForUser(userId);
    final list = await stream.first;

    expect(list, isNotEmpty);
    expect(list.any((r) => r.description == 'Request 1'), isTrue);
    expect(list.every((r) => r.userId == userId), isTrue);
  });

  test('provider profile lookup joins user and category', () async {
    final provider =
        await ServiceMarketplaceService.instance.providerById('sp-ravi');
    expect(provider, isNotNull);
    expect(provider!.user?.fullName, isNotEmpty);
    expect(provider.category?.name, 'Electrician');
  });

  test('guest can register as a provider once', () async {
    final profile = await ServiceMarketplaceService.instance.register(
      userId: GuestAuthUser.guestUid,
      categoryId: 'scat-electric',
      experienceYears: '5',
      hourlyRate: '200',
      bio: 'Fan and wiring repair in Degloor.',
    );
    expect(profile, isA<ServiceProviderProfile>());
    expect(profile, isNot(isA<ServiceProvidersRow>()));
    expect(profile.userId, GuestAuthUser.guestUid);
    expect(profile.categoryId, 'scat-electric');
    expect(profile.experienceYears, 5);
    expect(profile.hourlyRate, 200);
    expect(profile.isVerified, isFalse);
    expect(
      await UserService.instance.roleFor(GuestAuthUser.guestUid),
      'service_provider',
    );

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

    final done = ServiceMarketplaceService.instance.requestActions('completed');
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

  test('Java marketplace JSON maps to domain types', () {
    final category = ServiceCategory.fromJson({
      'id': 'scat-electric',
      'name': 'Electrician',
      'iconName': 'bolt',
    });
    expect(category, isA<ServiceCategory>());
    expect(category.id, 'scat-electric');
    expect(category.name, 'Electrician');
    expect(category.iconName, 'bolt');

    final card = ServiceProviderCard.fromJson({
      'id': 'sp-ravi',
      'userId': 'user-electrician',
      'categoryId': 'scat-electric',
      'bio': 'Wiring in Degloor.',
      'hourlyRate': 200,
      'experienceYears': 5,
      'verified': true,
      'fullName': 'Ravi',
      'avatarUrl': 'https://example.com/a.png',
    }, category: const JoinedCategory(name: 'Electrician'));
    expect(card.id, 'sp-ravi');
    expect(card.userId, 'user-electrician');
    expect(card.hourlyRate, 200);
    expect(card.isVerified, isTrue);
    expect(card.categoryName, 'Electrician');
    expect(card.displayName, 'Ravi');
    expect(card.photoUrl, 'https://example.com/a.png');

    final profile = ServiceProviderProfile.fromJson({
      'id': 'sp-ravi',
      'userId': 'user-electrician',
      'categoryId': 'scat-electric',
      'bio': 'Wiring in Degloor.',
      'hourlyRate': 200,
      'experienceYears': 5,
      'verified': false,
    });
    expect(profile, isA<ServiceProviderProfile>());
    expect(profile.userId, 'user-electrician');
    expect(profile.isVerified, isFalse);
    expect(profile.createdAt.millisecondsSinceEpoch, 0);

    final request = ServiceRequest.fromJson({
      'id': 'sr-1',
      'userId': GuestAuthUser.guestUid,
      'providerId': 'sp-ravi',
      'description': 'Fix the tube light.',
      'status': 'pending',
      'scheduledAt': '2026-08-25T10:00:00Z',
      'createdAt': '2026-08-24T10:00:00Z',
    });
    expect(request, isA<ServiceRequest>());
    expect(request.id, 'sr-1');
    expect(request.providerId, 'sp-ravi');
    expect(request.status, 'pending');
    expect(request.createdAt.toUtc().year, 2026);
    expect(request.user, isNull);

    final named = ServiceRequest.fromJson({
      'id': 'sr-2',
      'userId': GuestAuthUser.guestUid,
      'providerId': 'sp-ravi',
      'description': 'Fix the tube light.',
      'status': 'pending',
      'fullName': 'Asha Patil',
      'phoneNumber': '9876543210',
      'avatarUrl': 'https://example.com/asha.png',
    });
    expect(
      named.user?.displayName(fallback: 'Unknown Customer'),
      'Asha Patil',
    );
    expect(named.user?.phoneNumber, '9876543210');
    expect(named.photoUrl, 'https://example.com/asha.png');
    expect(request.photoUrl, isNull);
  });

  test('guest join as provider persists when live providers are empty', () async {
    AppEnvironment.debugReset();
    AppEnvironment.debugOverride(
      flavor: AppFlavor.development,
      bypassAuth: true,
      useShowcaseData: false,
    );
    AppEnvironment.markFlutterFlowHostLive();
    addTearDown(() {
      AppEnvironment.debugReset();
      AppEnvironment.debugOverride(
        flavor: AppFlavor.development,
        bypassAuth: true,
        useShowcaseData: true,
      );
    });
    expect(kUseShowcaseData, isFalse);

    final categories = await ServiceMarketplaceService.instance.categories();
    expect(categories.map((row) => row.id), contains('scat-electric'));

    final profile = await ServiceMarketplaceService.instance.register(
      userId: GuestAuthUser.guestUid,
      categoryId: 'scat-electric',
      experienceYears: '5',
      hourlyRate: '200',
      bio: 'Fan and wiring repair in Degloor.',
    );
    expect(profile, isA<ServiceProviderProfile>());
    expect(profile.userId, GuestAuthUser.guestUid);
    expect(profile.id, startsWith('service_providers-'));
    expect(profile.hourlyRate, 200);

    final listed = await ServiceMarketplaceService.instance.providers();
    expect(
      listed.items.map((row) => row.userId),
      contains(GuestAuthUser.guestUid),
    );
    expect(
      listed.items.where((row) => row.id.startsWith('sp-')),
      isEmpty,
    );
    expect(
      listed.items
          .singleWhere((row) => row.userId == GuestAuthUser.guestUid)
          .displayName,
      'Guest Customer',
    );

    final again = await ServiceMarketplaceService.instance.forUser(
      GuestAuthUser.guestUid,
    );
    expect(again!.id, profile.id);

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

  test('Java write JSON maps to provider profile and request', () {
    final profile = ServiceProviderProfile.fromJson({
      'id': 'sp-ravi',
      'userId': GuestAuthUser.guestUid,
      'categoryId': 'scat-electric',
      'bio': 'Fan and wiring repair in Degloor.',
      'hourlyRate': 200,
      'experienceYears': 5,
      'verified': false,
    });
    expect(profile, isA<ServiceProviderProfile>());
    expect(profile.userId, GuestAuthUser.guestUid);
    expect(profile.categoryId, 'scat-electric');
    expect(profile.hourlyRate, 200);
    expect(profile.experienceYears, 5);
    expect(profile.isVerified, isFalse);

    final request = ServiceRequest.fromJson({
      'id': 'sr-1',
      'userId': GuestAuthUser.guestUid,
      'providerId': 'sp-ravi',
      'description': 'Fix the kitchen tube light.',
      'status': 'pending',
      'scheduledAt': '2026-08-25T10:00:00Z',
      'createdAt': '2026-08-24T10:00:00Z',
    });
    expect(request, isA<ServiceRequest>());
    expect(request.id, 'sr-1');
    expect(request.providerId, 'sp-ravi');
    expect(request.status, 'pending');
    expect(request.createdAt.toUtc().year, 2026);
  });

  test('live join as provider promotes the guest off Customer', () async {
    AppEnvironment.debugReset();
    AppEnvironment.debugOverride(
      flavor: AppFlavor.development,
      bypassAuth: true,
      useShowcaseData: false,
    );
    AppEnvironment.markFlutterFlowHostLive();
    addTearDown(() {
      AppEnvironment.debugReset();
      AppEnvironment.debugOverride(
        flavor: AppFlavor.development,
        bypassAuth: true,
        useShowcaseData: true,
      );
    });
    installGuestSession();
    expect(kUseShowcaseData, isFalse);
    expect(currentUser?.role, 'customer');

    await ServiceMarketplaceService.instance.register(
      userId: GuestAuthUser.guestUid,
      categoryId: 'scat-electric',
      experienceYears: '5',
      hourlyRate: '200',
      bio: 'Fan and wiring repair in Degloor.',
    );
    expect(currentUser?.role, 'service_provider');
    expect(
      await UserService.instance.roleFor(GuestAuthUser.guestUid),
      'service_provider',
    );
  });
}
