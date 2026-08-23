import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/components/empty_state_view.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('empty state shows title, description, and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyStateView(
            icon: Icons.shopping_cart_outlined,
            title: 'Your cart is empty',
            description: 'Add something nearby.',
            buttonText: 'Browse shops',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Add something nearby.'), findsOneWidget);
    await tester.tap(find.text('Browse shops'));
    expect(tapped, isTrue);
  });

  testWidgets('empty state fits a short viewport under a header', (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 120, child: ColoredBox(color: Colors.grey)),
              Expanded(
                child: EmptyStateView(
                  icon: Icons.handyman_outlined,
                  title: 'No providers here',
                  description:
                      'Service listings are unavailable until the server is restored.',
                  buttonText: 'Offer a service',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('No providers here'), findsOneWidget);
    expect(find.text('Offer a service'), findsOneWidget);
  });
}
