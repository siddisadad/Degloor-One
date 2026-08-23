import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/features/home/customer_home_widget.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    ShowcaseCatalog.reset();
    FFAppState.reset();
    SharedPreferences.setMockInitialValues({});
    await FFAppState.instance.initializePersistedState();
    FFAppState.instance.userLocation = ShowcaseCatalog.degloor;
  });

  testWidgets('home shows the local marketplace in five seconds', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider<FFAppState>.value(
        value: FFAppState.instance,
        child: const MaterialApp(
          home: CustomerHomeWidget(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Degloor'), findsWidgets);
    expect(find.text('Search anything...'), findsOneWidget);
    expect(find.text('Everything local,\nin one app.'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Services'), findsWidgets);
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Nearby Businesses'), findsOneWidget);
    expect(find.text('Popular Near You'), findsNothing);
    expect(find.text('Recommended for You'), findsNothing);
    expect(find.text('Local Services'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Popular Products'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('Services Near You'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
  });
}
