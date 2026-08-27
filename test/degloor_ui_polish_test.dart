import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/components/degloor_filter_chip.dart';
import 'package:degloor_one/components/modern/modern_product_card.dart';
import 'package:degloor_one/features/notifications/notifications_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('filter chip reports taps without overflowing', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DegloorFilterChip(
            label: 'Open now',
            selected: true,
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('Open now'), findsOneWidget);
    await tester.tap(find.text('Open now'));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signed-out inbox shows the empty-state copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsWidget(),
      ),
    );
    await tester.pump();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text("You're all caught up"), findsOneWidget);
    expect(find.text('Back to home'), findsOneWidget);
  });

  testWidgets('product card uses a local placeholder when there is no photo',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 164,
            child: ModernProductCard(
              name: 'Milk',
              price: 28,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.image_not_supported_rounded), findsOneWidget);
  });
}
