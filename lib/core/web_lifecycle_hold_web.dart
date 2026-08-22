import 'dart:js_interop';

/// Lets window focus/blur reach Flutter after the lifecycle handler is bound.
void releaseHeldBrowserLifecycle() {
  final release = globalContext.getProperty('__degloorReleaseLifecycle'.toJS);
  if (release.isA<JSFunction>()) {
    (release as JSFunction).callAsFunction();
  }
}
