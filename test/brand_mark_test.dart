import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/components/home_feature_shortcuts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('brand mark shows DEGLOOR ONE wordmark', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: BrandMark(showWordmark: true)),
        ),
      ),
    );

    expect(find.text('DEGLOOR ONE'), findsOneWidget);
    expect(find.text('Everything Local. One App.'), findsOneWidget);
    expect(find.text('D1'), findsOneWidget);
  });

  testWidgets('home shortcuts expose services, jobs, and orders',
      (tester) async {
    var tapped = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeFeatureShortcuts(
            onServices: () => tapped = 'services',
            onJobs: () => tapped = 'jobs',
            onOrders: () => tapped = 'orders',
          ),
        ),
      ),
    );

    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    await tester.tap(find.text('Jobs'));
    expect(tapped, 'jobs');
  });
}
