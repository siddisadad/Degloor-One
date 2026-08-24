import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/features/profile/user_profile_reports_widget.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    ShowcaseCatalog.reset();
    installGuestSession();
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
}
