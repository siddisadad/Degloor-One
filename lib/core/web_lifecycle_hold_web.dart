import 'dart:js_interop';
import 'dart:js_interop_unsafe';

void holdBrowserLifecycle() {
  final hold = globalContext.getProperty('__degloorHoldLifecycle'.toJS);
  if (hold.isA<JSFunction>()) {
    (hold as JSFunction).callAsFunction();
  }
}

void releaseHeldBrowserLifecycle() {
  final release = globalContext.getProperty('__degloorReleaseLifecycle'.toJS);
  if (release.isA<JSFunction>()) {
    (release as JSFunction).callAsFunction();
  }
}
