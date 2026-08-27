import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/features/profile/profile_info_widget.dart';

void main() {
  testWidgets('Help Center shows contact support and sections', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileInfoWidget(kind: ProfileInfoKind.helpCenter),
      ),
    );

    expect(find.text('Help Center'), findsOneWidget);
    expect(find.text('Need direct help?'), findsOneWidget);
    expect(find.text('Contact Support'), findsOneWidget);
    expect(find.text('Find shops'), findsOneWidget);
  });

  testWidgets('Privacy Policy renders correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileInfoWidget(kind: ProfileInfoKind.privacyPolicy),
      ),
    );

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Data Collection'), findsOneWidget);
    expect(find.text('Your Choices'), findsOneWidget);
  });

  testWidgets('Terms of Service renders correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileInfoWidget(kind: ProfileInfoKind.termsOfService),
      ),
    );

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('A local marketplace'), findsOneWidget);
  });
}
