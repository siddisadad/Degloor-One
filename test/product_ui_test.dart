import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/components/modern/modern_product_list_item.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await FlutterFlowTheme.initialize();
  });

  testWidgets('ModernProductListItem shows LIMITED STOCK when quantity is low',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ModernProductListItem(
            name: 'Low Stock Item',
            price: 100,
            stockQuantity: 3,
            trackInventory: true,
          ),
        ),
      ),
    );

    expect(find.text('LIMITED STOCK'), findsOneWidget);
  });

  testWidgets('ModernProductListItem shows OUT OF STOCK when quantity is 0',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ModernProductListItem(
            name: 'Empty Item',
            price: 100,
            stockQuantity: 0,
            trackInventory: true,
          ),
        ),
      ),
    );

    expect(find.text('OUT OF\nSTOCK'), findsOneWidget);
    expect(find.text('LIMITED STOCK'), findsNothing);
  });

  testWidgets('ModernProductListItem does not show badges when inventory is not tracked',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ModernProductListItem(
            name: 'Untracked Item',
            price: 100,
            stockQuantity: 0,
          ),
        ),
      ),
    );

    expect(find.text('OUT OF\nSTOCK'), findsNothing);
    expect(find.text('LIMITED STOCK'), findsNothing);
  });
}
