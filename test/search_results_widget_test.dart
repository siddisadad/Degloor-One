import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/features/search/search_results_widget.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
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

  testWidgets('master search field accepts a query and shows product hits',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchResultsWidget(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('All'), findsWidgets);
    expect(find.text('Products'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'milk');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Fresh Milk (1L)'), findsWidgets);
    expect(find.textContaining('Patil'), findsWidgets);
  });

  testWidgets('search back arrow pops a pushed results page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SearchResultsWidget(),
                  ),
                );
              },
              child: const Text('Open search'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Open search'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
