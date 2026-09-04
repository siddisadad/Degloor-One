import 'dart:async';

import 'package:degloor_one/core/java_polling_stream.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emits immediately and on each interval', () async {
    var calls = 0;
    final stream = javaPollingStream(
      () async => ++calls,
      interval: const Duration(milliseconds: 50),
    );

    final values = <int>[];
    final sub = stream.listen(values.add);
    await Future<void>.delayed(const Duration(milliseconds: 130));
    await sub.cancel();

    expect(calls, greaterThanOrEqualTo(2));
    expect(values, isNotEmpty);
    expect(values.first, 1);
  });

  test('keeps polling after fetch errors', () async {
    var calls = 0;
    final stream = javaPollingStream<int>(
      () async {
        calls++;
        if (calls == 1) {
          throw Exception('transient');
        }
        return calls;
      },
      interval: const Duration(milliseconds: 30),
    );

    final values = <int>[];
    final sub = stream.listen(values.add);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await sub.cancel();

    expect(values, isNotEmpty);
    expect(values.any((value) => value >= 2), isTrue);
  });

  test('stops polling when cancelled', () async {
    var calls = 0;
    final stream = javaPollingStream(
      () async => ++calls,
      interval: const Duration(milliseconds: 20),
    );

    final sub = stream.listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 45));
    await sub.cancel();
    final countAfterCancel = calls;
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(calls, countAfterCancel);
  });
}
