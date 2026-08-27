import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/features/home/customer_home_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_model.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Shop _shop(String id, DateTime createdAt) {
  return Shop(
    id: id,
    name: id,
    createdAt: createdAt,
  );
}

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

  testWidgets('home shows the local marketplace in five seconds',
      (tester) async {
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
    expect(find.text('New in Degloor'), findsOneWidget);
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

  testWidgets('home model keeps the newest shops first', (tester) async {
    late CustomerHomeModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => CustomerHomeModel());
        return const SizedBox.shrink();
      }),
    ));

    final newest = model.newestShops([
      _shop('old', DateTime.utc(2024)),
      _shop('new', DateTime.utc(2026, 8, 25)),
      _shop('mid', DateTime.utc(2025, 6)),
    ]);
    expect(newest.map((shop) => shop.id), ['new', 'mid', 'old']);
    expect(
      model.newestShops([
        for (var i = 0; i < 8; i++)
          _shop('shop-$i', DateTime.utc(2026, 1, i + 1)),
      ]).map((shop) => shop.id),
      ['shop-7', 'shop-6', 'shop-5', 'shop-4', 'shop-3'],
    );
  });

  testWidgets('home model loads new shops from discovery', (tester) async {
    late CustomerHomeModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => CustomerHomeModel());
        return const SizedBox.shrink();
      }),
    ));

    model.loadNewBusinesses(radiusKm: 5);
    expect(await model.newBusinessesFuture, isEmpty);

    model.loadNewBusinesses(
      latitude: ShowcaseCatalog.degloorLat,
      longitude: ShowcaseCatalog.degloorLng,
      radiusKm: 5,
    );
    final shops = await model.newBusinessesFuture!;
    expect(shops, isNotEmpty);
    expect(shops.length, lessThanOrEqualTo(5));
    for (var i = 1; i < shops.length; i++) {
      expect(
        shops[i - 1].createdAt.isBefore(shops[i].createdAt),
        isFalse,
      );
    }
  });
}
