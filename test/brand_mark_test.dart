import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/components/auth_page_header.dart';
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

  testWidgets('compact brand mark fits a narrow start-aligned column',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrandMark(size: 56, showWordmark: true, compact: true),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('DEGLOOR ONE'), findsOneWidget);
  });

  testWidgets('compact brand mark fits a 280px auth-style column',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(280, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrandMark(size: 56, showWordmark: true, compact: true),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('DEGLOOR ONE'), findsOneWidget);
  });

  testWidgets('compact brand mark shows the wordmark', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BrandMark(size: 40, showWordmark: true, compact: true),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('DEGLOOR ONE'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('compact brand mark fits beside siblings in a header row',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 120));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Flexible(
                  child: BrandMark(size: 40, showWordmark: true, compact: true),
                ),
                SizedBox(width: 12),
                Expanded(child: Text('Degloor, Maharashtra')),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('DEGLOOR ONE'), findsOneWidget);
    expect(find.text('Degloor, Maharashtra'), findsOneWidget);
  });

  testWidgets('auth page header shows brand, title, and subtitle',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 320));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(24),
            child: AuthPageHeader(
              title: 'Forgot password',
              subtitle: 'Enter the email on your account.',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('DEGLOOR ONE'), findsOneWidget);
    expect(find.text('Forgot password'), findsOneWidget);
    expect(find.text('Enter the email on your account.'), findsOneWidget);
  });

  testWidgets('auth page scaffold keeps forms at a readable width',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthPageScaffold(
            child: SizedBox(width: double.infinity, height: 40),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SizedBox)).width, 520);
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
