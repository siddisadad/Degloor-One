import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/database/tables/users_table.dart';
import 'package:degloor_one/core/app_environment.dart';
import 'package:degloor_one/data/datasources/bind_user_service.dart';
import 'package:degloor_one/data/repositories/user_repository.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'package:degloor_one/shared/user_profile_draft.dart';
import 'package:degloor_one/shared/user_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'supabase_initializer.dart';

class _EmptyUserRepository implements UserRepository {
  @override
  Future<UserProfile?> byId(String userId) async => null;

  @override
  Future<List<UserProfile>> byIds(List<String> ids) async => const [];

  @override
  Future<UserProfile> insert(
    UserProfileDraft draft, {
    required String userId,
  }) {
    throw UnsupportedError('insert is not used by the guest fallback');
  }

  @override
  Future<UserProfile?> update(String userId, UserProfileDraft draft) async {
    return null;
  }

  @override
  Future<void> probe() async {}
}

class _NamedGuestRepository implements UserRepository {
  @override
  Future<UserProfile?> byId(String userId) async {
    if (userId != GuestAuthUser.guestUid) return null;
    return const UserProfile(
      id: GuestAuthUser.guestUid,
      fullName: 'Live Guest',
      email: 'live-guest@degloor.local',
      role: 'customer',
    );
  }

  @override
  Future<List<UserProfile>> byIds(List<String> ids) async {
    final row = await byId(GuestAuthUser.guestUid);
    return ids.contains(GuestAuthUser.guestUid) && row != null
        ? [row]
        : const [];
  }

  @override
  Future<UserProfile> insert(
    UserProfileDraft draft, {
    required String userId,
  }) {
    throw UnsupportedError('insert is not used by the guest fallback');
  }

  @override
  Future<UserProfile?> update(String userId, UserProfileDraft draft) async {
    return null;
  }

  @override
  Future<void> probe() async {}
}

void main() {
  setUpAll(() async {
    await initializeMockSupabase();
  });

  setUp(ShowcaseCatalog.reset);

  test('guest profile and admin role use the showcase catalog', () async {
    final profile =
        await UserService.instance.profile(GuestAuthUser.guestUid);
    expect(profile, hasLength(1));
    expect(profile.single, isA<UserProfile>());
    expect(profile.single, isNot(isA<UsersRow>()));
    expect(profile.single.fullName, 'Guest Customer');
    expect(profile.single.email, 'guest@local');
    expect(profile.single.phoneNumber, '+919890000001');
    expect(profile.single.role, 'customer');

    expect(
      await UserService.instance.roleFor(ShowcaseCatalog.adminId),
      'admin',
    );
    expect(await UserService.instance.roleFor(''), isNull);
    expect(await UserService.instance.byId('user-missing'), isNull);
  });

  test('byIds returns only the requested users', () async {
    final rows = await UserService.instance.byIds([
      GuestAuthUser.guestUid,
      ShowcaseCatalog.adminId,
      '',
    ]);
    expect(rows.map((row) => row.id), unorderedEquals([
      GuestAuthUser.guestUid,
      ShowcaseCatalog.adminId,
    ]));
  });

  test('ensureOnSignIn creates a customer once', () async {
    const newId = '00000000-0000-4000-8000-000000000021';
    final created = await UserService.instance.ensureOnSignIn(
      userId: newId,
      draft: UserProfileDraft.fromSignIn(
        email: 'asha@degloor.local',
        phone: '+919890000021',
        fullName: 'Asha Patil',
      ),
    );
    expect(created.role, 'customer');
    expect(created.fullName, 'Asha Patil');

    final again = await UserService.instance.ensureOnSignIn(
      userId: newId,
      draft: UserProfileDraft.fromSignIn(
        email: 'other@degloor.local',
        fullName: 'Other',
      ),
    );
    expect(again.id, newId);
    expect(again.fullName, 'Asha Patil');
    expect(again.email, 'asha@degloor.local');
  });

  test('updateProfile changes the guest name and phone', () async {
    await UserService.instance.updateProfile(
      userId: GuestAuthUser.guestUid,
      draft: UserProfileDraft.fromProfile(
        fullName: '  Sadad Guest  ',
        phoneNumber: '+919890009999',
      ),
    );
    final row = await UserService.instance.byId(GuestAuthUser.guestUid);
    expect(row!.fullName, 'Sadad Guest');
    expect(row.phoneNumber, '+919890009999');
  });

  test('updateProfile rejects a missing user', () async {
    await expectLater(
      UserService.instance.updateProfile(
        userId: 'user-missing',
        draft: UserProfileDraft.fromProfile(fullName: 'Nope'),
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Profile not found'),
        ),
      ),
    );
  });

  test('probeReachable succeeds against the showcase catalog', () async {
    await UserService.instance.probeReachable();
  });

  test('roleFor reads the catalog when live users is empty', () async {
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

    expect(await UserService.instance.roleFor(GuestAuthUser.guestUid),
        'customer');

    ShowcaseCatalog.update(
      'users',
      UserRole.serviceProvider.toUpdateJson(),
      ShowcaseQuery()..eq('id', GuestAuthUser.guestUid),
    );
    expect(
      await UserService.instance.roleFor(GuestAuthUser.guestUid),
      'service_provider',
    );
  });

  test('guest uid falls back when the repository has no users row', () async {
    UserService.bind(_EmptyUserRepository());
    addTearDown(bindUserService);

    final profile = await UserService.instance.profile(GuestAuthUser.guestUid);
    expect(profile, hasLength(1));
    expect(profile.single.fullName, 'Guest Customer');
    expect(profile.single.email, 'guest@local');
    expect(profile.single.phoneNumber, '+919890000001');
    expect(profile.single.role, 'customer');
    expect(await UserService.instance.roleFor(GuestAuthUser.guestUid),
        'customer');
    expect(await UserService.instance.byId('user-missing'), isNull);

    final rows = await UserService.instance.byIds([
      GuestAuthUser.guestUid,
      'user-missing',
    ]);
    expect(rows.map((row) => row.id), [GuestAuthUser.guestUid]);
    expect(rows.single.fullName, 'Guest Customer');
  });

  test('guest fallback does not replace a live users row', () async {
    UserService.bind(_NamedGuestRepository());
    addTearDown(bindUserService);

    final row = await UserService.instance.byId(GuestAuthUser.guestUid);
    expect(row!.fullName, 'Live Guest');
    expect(row.email, 'live-guest@degloor.local');

    final rows = await UserService.instance.byIds([GuestAuthUser.guestUid]);
    expect(rows, hasLength(1));
    expect(rows.single.fullName, 'Live Guest');
  });
}
