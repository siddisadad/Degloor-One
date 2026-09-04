import 'dart:async';

import 'package:degloor_one/core/async_coalesce.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coalesceInFlight shares one in-flight result with waiters', () async {
    Completer<int>? inFlight;
    var runs = 0;
    final started = Completer<void>();
    final release = Completer<void>();

    Future<int> action() async {
      runs += 1;
      started.complete();
      await release.future;
      return 42;
    }

    final first = coalesceInFlight<int>(
      inFlight: inFlight,
      setInFlight: (c) => inFlight = c,
      action: action,
    );
    await started.future;
    expect(inFlight, isNotNull);

    final second = coalesceInFlight<int>(
      inFlight: inFlight,
      setInFlight: (c) => inFlight = c,
      action: action,
    );

    release.complete();
    expect(await Future.wait([first, second]), [42, 42]);
    expect(runs, 1);
    expect(inFlight, isNull);
  });

  test('coalesceInFlight propagates errors to waiters', () async {
    Completer<int>? inFlight;
    final started = Completer<void>();
    final release = Completer<void>();

    Future<int> action() async {
      started.complete();
      await release.future;
      throw StateError('boom');
    }

    final first = coalesceInFlight<int>(
      inFlight: inFlight,
      setInFlight: (c) => inFlight = c,
      action: action,
    );
    await started.future;
    final second = coalesceInFlight<int>(
      inFlight: inFlight,
      setInFlight: (c) => inFlight = c,
      action: action,
    );

    release.complete();
    await expectLater(first, throwsStateError);
    await expectLater(second, throwsStateError);
    expect(inFlight, isNull);
  });
}
