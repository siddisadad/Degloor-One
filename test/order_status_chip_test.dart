import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/components/order_list_card.dart';
import 'package:degloor_one/components/order_status_chip.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('status chip uses a human label and does not overflow',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: OrderStatusChip(status: OrderLifecycle.outForDelivery),
          ),
        ),
      ),
    );

    expect(find.text('Out for delivery'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('order card clips a long shop name at phone width',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: OrderListCard(
              title:
                  'Patil Kirana and General Stores of Degloor Market Road with a very long name',
              orderId: 'order-out-for-delivery-id',
              createdAt: DateTime(2026, 8, 22, 18, 30),
              totalAmount: 1245.5,
              status: OrderLifecycle.outForDelivery,
              subtitle: '+91 98765 43210',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('Order #order-ou'), findsOneWidget);
    expect(find.text('Out for delivery'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
