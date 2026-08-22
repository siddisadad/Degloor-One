import 'dart:js_interop';

/// JS function installed by `web/flutter_bootstrap.js`.
@JS('__degloorReleaseLifecycle')
external JSFunction? get _degloorReleaseLifecycle;

/// Lets window focus/blur reach Flutter after the lifecycle handler is bound.
void releaseHeldBrowserLifecycle() {
  try {
    _degloorReleaseLifecycle?.callAsFunction();
  } catch (_) {
    // Missing when widget tests run without the web bootstrap script.
  }
}
