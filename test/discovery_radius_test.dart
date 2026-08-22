import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/components/discovery_radius_bar.dart';
import 'package:degloor_one/shared/discovery_radius.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('discovery radius helpers', () {
    test('allowed options are 5, 10, and 15 km', () {
      expect(kDiscoveryRadiiKm, [5, 10, 15]);
    });

    test('snaps retired 2 km and 25 km onto the nearest option', () {
      expect(snapDiscoveryRadius(2), 5);
      expect(snapDiscoveryRadius(25), 15);
      expect(snapDiscoveryRadius(7), 5);
      expect(snapDiscoveryRadius(8), 10);
      expect(snapDiscoveryRadius(13), 15);
      expect(snapDiscoveryRadius(10), 10);
    });

    test('slider percent maps onto 5 / 10 / 15', () {
      expect(radiusFromSliderPercent(0), 5);
      expect(radiusFromSliderPercent(50), 10);
      expect(radiusFromSliderPercent(100), 15);
      expect(sliderPercentFromRadius(10), 50);
      expect(sliderPercentFromRadius(2), 0);
      expect(sliderPercentFromRadius(25), 100);
    });

    test('next radius stops at 15 km', () {
      expect(nextDiscoveryRadius(5), 10);
      expect(nextDiscoveryRadius(10), 15);
      expect(nextDiscoveryRadius(15), isNull);
      expect(nextDiscoveryRadius(2), 10);
      expect(nextDiscoveryRadius(25), isNull);
    });
  });

  testWidgets('radius bar shows only 5, 10, and 15 km', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var selected = 10.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
              builder: (context, setState) {
                return DiscoveryRadiusBar(
                  selectedKm: selected,
                  openNow: false,
                  onChanged: (radius) => setState(() => selected = radius),
                  onOpenNowToggle: () {},
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('5 km'), findsOneWidget);
    expect(find.text('10 km'), findsOneWidget);
    expect(find.text('15 km'), findsOneWidget);
    expect(find.text('2 km'), findsNothing);
    expect(find.text('25 km'), findsNothing);
    expect(find.text('Open now'), findsOneWidget);

    await tester.tap(find.text('15 km'));
    await tester.pumpAndSettle();
    expect(selected, 15);
  });
}
