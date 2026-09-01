import 'dart:async';

/// Polls [fetch] for Java API screens that lack Supabase realtime.
///
/// Emits immediately on listen, then on each [interval]. Transient errors are
/// swallowed so a single failed request does not close the stream.
Stream<T> javaPollingStream<T>(
  Future<T> Function() fetch, {
  Duration interval = const Duration(seconds: 15),
}) {
  late final StreamController<T> controller;
  Timer? timer;
  var inFlight = false;

  Future<void> tick() async {
    if (inFlight || controller.isClosed) return;
    inFlight = true;
    try {
      final value = await fetch();
      if (!controller.isClosed) {
        controller.add(value);
      }
    } catch (_) {
      // Keep polling after transient API errors.
    } finally {
      inFlight = false;
    }
  }

  controller = StreamController<T>(
    onListen: () {
      unawaited(tick());
      timer = Timer.periodic(interval, (_) => unawaited(tick()));
    },
    onCancel: () {
      timer?.cancel();
      timer = null;
    },
  );

  return controller.stream;
}
