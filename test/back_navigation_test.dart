import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/features/cart/cart_widget.dart';
import 'package:degloor_one/features/orders/order_success_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('shared back button pops the current route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        leading: degloorBackButton(context),
                      ),
                      body: const Text('Inner page'),
                    ),
                  ),
                );
              },
              child: const Text('Open inner'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open inner'));
    await tester.pumpAndSettle();
    expect(find.text('Inner page'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Open inner'), findsOneWidget);
    expect(find.text('Inner page'), findsNothing);
  });

  testWidgets('order success shows a back arrow', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OrderSuccessWidget(orderId: 'order-12345678'),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('Order placed'), findsOneWidget);
  });

  testWidgets('local services app bar keeps a back arrow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            appBar: degloorAppBar(context, title: 'Find local services'),
          ),
        ),
      ),
    );

    expect(find.text('Find local services'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('cart tab shows a back arrow', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CartWidget(),
      ),
    );
    await tester.pump();

    expect(find.text('Your Cart'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('tab-style pages hide back when they cannot pop', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(leading: degloorBackLeading(context)),
            body: const Text('Tab root'),
          ),
        ),
      ),
    );

    expect(find.text('Tab root'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });
}
