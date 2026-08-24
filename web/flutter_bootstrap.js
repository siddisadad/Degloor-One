{{flutter_js}}
{{flutter_build_config}}

// Do not intercept window focus/blur/visibilitychange. Capture-phase
// stopImmediatePropagation delays Chrome's Debugger.enable, and DWDS
// then fails after 5s: "Failed to connect to the web debug service".
// Early flutter/lifecycle messages are held in Dart via channelBuffers.
_flutter.loader.load();
