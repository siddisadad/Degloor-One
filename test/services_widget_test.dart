import 'package:degloor_one/features/services/services_widget.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(ShowcaseCatalog.reset);

  testWidgets('services page lists categories and providers', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ServicesWidget(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Find local services'), findsOneWidget);
    expect(find.text('Electrician'), findsWidgets);
    expect(find.text('Ravi Electrician'), findsOneWidget);
  });
}
