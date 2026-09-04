import 'dart:async';

/// Runs [action] once; concurrent callers await the same in-flight result.
Future<T> coalesceInFlight<T>({
  required Completer<T>? inFlight,
  required void Function(Completer<T>?) setInFlight,
  required Future<T> Function() action,
}) async {
  final existing = inFlight;
  if (existing != null) return existing.future;

  final completer = Completer<T>();
  setInFlight(completer);
  try {
    final value = await action();
    if (!completer.isCompleted) {
      completer.complete(value);
    }
    return value;
  } catch (error, stackTrace) {
    if (!completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
    rethrow;
  } finally {
    setInFlight(null);
  }
}
