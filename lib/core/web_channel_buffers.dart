import 'dart:ui' as ui;

import 'web_lifecycle_hold_stub.dart'
    if (dart.library.js_interop) 'web_lifecycle_hold_web.dart';

export 'web_lifecycle_hold_stub.dart'
    if (dart.library.js_interop) 'web_lifecycle_hold_web.dart';

/// Flutter web's engine sends window focus/blur on this channel as soon as
/// [PlatformDispatcher] starts, before [WidgetsFlutterBinding] registers a
/// listener. The default buffer holds one message, so Chrome prints
/// "A message on the flutter/lifecycle channel was discarded".
const kLifecycleChannel = 'flutter/lifecycle';

/// Queue early lifecycle events and stop the debug discard warning.
///
/// Call this before [WidgetsFlutterBinding.ensureInitialized], then call
/// [releaseHeldBrowserLifecycle] after the binding is ready. Do not wrap
/// `window.addEventListener` in `web/flutter_bootstrap.js` — dropping
/// focus/blur races AppInspector's Runtime.evaluate against a dead context.
void acceptEarlyLifecycleMessages() {
  holdBrowserLifecycle();
  ui.channelBuffers.resize(kLifecycleChannel, 20);
  ui.channelBuffers.allowOverflow(kLifecycleChannel, true);
}
