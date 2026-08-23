import 'package:degloor_one/features/catalogue/product_detail_widget.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(ShowcaseCatalog.reset);

  testWidgets('product detail shows Patil milk from ShopService', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailWidget(productId: ShowcaseCatalog.prodMilk),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Fresh Milk (1L)'), findsOneWidget);
    expect(find.text('₹60'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
    expect(
      find.text('Pure buffalo milk from nearby dairies.'),
      findsOneWidget,
    );
  });

  testWidgets('unknown product shows an empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProductDetailWidget(productId: 'prod-missing'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Product not found'), findsOneWidget);
    expect(find.text('Add to Cart'), findsNothing);
  });
}
