import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/components/supabase_unreachable_banner.dart';

void main() {
  testWidgets('shows the unreachable host message by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SupabaseUnreachableBanner(),
        ),
      ),
    );

    expect(
      find.text(SupabaseConnection.unreachableMessage),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
