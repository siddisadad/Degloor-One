import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/features/profile/profile_info_widget.dart';
import 'package:degloor_one/features/profile/user_profile_reports_widget.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _profileApp() {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const UserProfileReportsWidget(showBack: false),
      ),
      GoRoute(
        path: ProfileInfoWidget.helpRoutePath,
        name: ProfileInfoWidget.helpRouteName,
        builder: (_, __) => const ProfileInfoWidget(
          kind: ProfileInfoKind.helpCenter,
        ),
      ),
      GoRoute(
        path: ProfileInfoWidget.termsRoutePath,
        name: ProfileInfoWidget.termsRouteName,
        builder: (_, __) => const ProfileInfoWidget(
          kind: ProfileInfoKind.termsOfService,
        ),
      ),
      GoRoute(
        path: ProfileInfoWidget.aboutRoutePath,
        name: ProfileInfoWidget.aboutRouteName,
        builder: (_, __) => const ProfileInfoWidget(
          kind: ProfileInfoKind.aboutApp,
        ),
      ),
    ],
  );
  return ChangeNotifierProvider<FFAppState>.value(
    value: FFAppState.instance,
    child: Consumer<FFAppState>(
      builder: (context, state, _) {
        return MaterialApp.router(
          locale: Locale(state.locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        );
      },
    ),
  );
}

Future<void> _openProfileTile(WidgetTester tester, String title) async {
  await tester.scrollUntilVisible(
    find.text(title),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    ShowcaseCatalog.reset();
    installGuestSession();
    FFAppState.reset();
    SharedPreferences.setMockInitialValues({});
    await FFAppState.instance.initializePersistedState();
  });

  testWidgets('profile loads the guest and saves personal information',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UserProfileReportsWidget(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('Guest Customer'), findsOneWidget);
    expect(find.text('guest@local'), findsOneWidget);

    await tester.tap(find.text('Personal Information'));
    await tester.pumpAndSettle();

    expect(find.text('Personal information'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Asha Patil');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Asha Patil'), findsOneWidget);
    expect(find.text('Guest Customer'), findsNothing);
    expect(find.text('Personal information'), findsNothing);
  });

  testWidgets('profile report opens the seeded complaint details',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: UserProfileReportsWidget(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.scrollUntilVisible(
      find.text('Missing sweet in thali'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Missing sweet in thali'));
    await tester.pumpAndSettle();

    expect(
      find.text('Yesterday’s thali did not include the advertised sweet.'),
      findsOneWidget,
    );
    expect(find.text('View shop'), findsOneWidget);
  });

  testWidgets('profile tab hides the back arrow', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UserProfileReportsWidget(showBack: false),
      ),
    );
    await tester.pump();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });

  testWidgets('profile opens Help, Terms, and About pages', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_profileApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await _openProfileTile(tester, 'Help Center');
    expect(find.text('Find shops'), findsOneWidget);
    expect(
      find.textContaining('shops, services, and jobs around Degloor'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await _openProfileTile(tester, 'Terms of Service');
    expect(find.text('A local marketplace'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await _openProfileTile(tester, 'About App');
    expect(find.text('Everything Local. One App.'), findsOneWidget);
    expect(find.text('DEGLOOR ONE'), findsOneWidget);
  });

  testWidgets('profile language switches to Hindi and Marathi', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_profileApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await _openProfileTile(tester, 'Language');
    await tester.tap(find.text('हिन्दी (Hindi)'));
    await tester.pumpAndSettle();

    expect(find.text('सहायता केंद्र'), findsOneWidget);
    expect(find.text('सेवा की शर्तें'), findsOneWidget);
    expect(find.text('ऐप के बारे में'), findsOneWidget);

    await _openProfileTile(tester, 'सहायता केंद्र');
    expect(find.text('दुकानें खोजें'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await _openProfileTile(tester, 'भाषा');
    await tester.tap(find.text('मराठी (Marathi)'));
    await tester.pumpAndSettle();

    expect(find.text('मदत केंद्र'), findsOneWidget);
    expect(find.text('सेवा अटी'), findsOneWidget);
    expect(find.text('अॅपबद्दल'), findsOneWidget);

    await _openProfileTile(tester, 'सेवा अटी');
    expect(find.text('स्थानिक मार्केटप्लेस'), findsOneWidget);
  });
}
