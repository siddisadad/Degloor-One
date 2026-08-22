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
                  icon: FontAwesomeIcons.google,
                  label: 'Google',
                ),
              ),
              Expanded(
                child: SocialButtonWidget(
                  icon: FontAwesomeIcons.apple,
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
    expect(find.byIcon(FontAwesomeIcons.google), findsOneWidget);
    expect(find.byIcon(FontAwesomeIcons.apple), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
