import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _barrel = "package:degloor_one/backend/supabase/supabase.dart";

void main() {
  test('screens and router do not import the Supabase table barrel', () {
    final roots = [
      Directory('lib/features'),
      Directory('lib/components'),
      Directory('lib/flutter_flow'),
    ];
    final offenders = <String>[];
    for (final root in roots) {
      if (!root.existsSync()) continue;
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (source.contains(_barrel)) {
          offenders.add(entity.path);
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
