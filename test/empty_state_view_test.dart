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
}
