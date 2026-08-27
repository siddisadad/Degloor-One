import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/components/location_explanation_dialog.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
      'location explanation sheet does not overflow at the reported size',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(640, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 592, maxHeight: 307.5),
              child: const LocationExplanationDialog(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Enable Location'), findsOneWidget);
    expect(find.text('Grant Permission'), findsOneWidget);
  });
}
