import 'dart:ui' as ui;

/// Flutter web's engine sends window focus/blur on this channel as soon as
/// [PlatformDispatcher] starts, before [WidgetsFlutterBinding] registers a
/// listener. The default buffer holds one message, so Chrome prints
/// "A message on the flutter/lifecycle channel was discarded".
const kLifecycleChannel = 'flutter/lifecycle';

/// Hold early lifecycle events and stop the debug discard warning.
///
/// Call this before [WidgetsFlutterBinding.ensureInitialized]. Do not swallow
/// those DOM events in `web/flutter_bootstrap.js` — that stalls DWDS.
void acceptEarlyLifecycleMessages() {
  ui.channelBuffers.resize(kLifecycleChannel, 20);
  ui.channelBuffers.allowOverflow(kLifecycleChannel, true);
}
