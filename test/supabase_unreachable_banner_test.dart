import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/components/supabase_unreachable_banner.dart';

void main() {
  testWidgets('guest mode does not show the restore-the-project banner',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SupabaseUnreachableBanner(),
        ),
      ),
    );

    expect(
      find.text(SupabaseConnection.unreachableMessage),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an explicit unreachable message from a live probe',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SupabaseUnreachableBanner(
            message: SupabaseConnection.unreachableMessage,
          ),
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
