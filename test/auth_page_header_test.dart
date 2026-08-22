import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/components/auth_page_header.dart';
import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/shared/otp_copy.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('auth header shows the brand mark and copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthPageHeader(
            title: 'Welcome to DEGLOOR ONE',
            subtitle: OtpCopy.phoneSubtitle,
          ),
        ),
      ),
    );

    expect(find.byType(BrandMark), findsOneWidget);
    expect(find.text('DEGLOOR ONE'), findsOneWidget);
    expect(find.text('Welcome to DEGLOOR ONE'), findsOneWidget);
    expect(find.text(OtpCopy.phoneSubtitle), findsOneWidget);
    expect(find.textContaining('6-digit'), findsOneWidget);
    expect(find.textContaining('4-digit'), findsOneWidget);
  });

  testWidgets('auth scaffold caps content at 520px', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthPageScaffold(
            child: SizedBox(width: double.infinity, height: 40),
          ),
        ),
      ),
    );

    final box = tester.renderObject<RenderBox>(find.byType(SizedBox));
    expect(box.size.width, AuthPageScaffold.maxWidth);
  });
}
