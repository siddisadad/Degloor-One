import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:degloor_one/components/social_button/social_button_widget.dart';

void main() {
  testWidgets('social buttons render local icons without a network SVG',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              Expanded(
                child: SocialButtonWidget(
                  icon: FaIcon(FontAwesomeIcons.google, size: 18),
                  label: 'Google',
                ),
              ),
              Expanded(
                child: SocialButtonWidget(
                  icon: FaIcon(FontAwesomeIcons.apple, size: 18),
                  label: 'Apple',
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.byType(FaIcon), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
