import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/components/home_feature_shortcuts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('brand mark loads the DEGLOOR ONE logo asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: BrandMark(size: 72, showWordmark: true)),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Everything Local. One App.'), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, kBrandImageAsset);
  });

  testWidgets('compact brand mark shows the wordmark', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BrandMark(size: 40, showWordmark: true, compact: true),
        ),
      ),
    );

    expect(find.text('DEGLOOR ONE'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
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
