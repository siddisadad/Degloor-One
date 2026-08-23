import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/components/modern/modern_product_card.dart';
import 'package:degloor_one/features/home/customer_home_widget.dart';
import 'package:degloor_one/flutter_flow/lat_lng.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home only refetches when location or radius changes', () {
    const degloor = ShowcaseCatalog.degloor;
    expect(
      discoveryInputsChanged(
        previousLocation: degloor,
        previousRadius: 15,
        nextLocation: degloor,
        nextRadius: 15,
      ),
      isFalse,
    );
    expect(
      discoveryInputsChanged(
        previousLocation: degloor,
        previousRadius: 15,
        nextLocation: degloor,
        nextRadius: 20,
      ),
      isTrue,
    );
    expect(
      discoveryInputsChanged(
        previousLocation: degloor,
        previousRadius: 15,
        nextLocation: const LatLng(18.55, 77.58),
        nextRadius: 15,
      ),
      isTrue,
    );
  });

  testWidgets('product card caches the remote image', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 164,
            child: ModernProductCard(
              name: 'Milk',
              price: 28,
              imageUrl: 'https://example.com/milk.jpg',
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });

  testWidgets('mem cache hint matches the on-screen size', (tester) async {
    late int cachePx;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(devicePixelRatio: 2),
        child: Builder(
          builder: (context) {
            cachePx = memCachePx(context, 70);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(cachePx, 140);
  });
}
