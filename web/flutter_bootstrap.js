{{flutter_js}}
{{flutter_build_config}}

// Do not wrap window.addEventListener or call stopImmediatePropagation.
// Dropping focus/blur/visibilitychange delayed DWDS long enough that
// AppInspector evaluated dartDevEmbedder in a destroyed JS context
// (Chrome "Cannot find context with specified id"). ChannelBuffers in
// Dart absorb the early flutter/lifecycle messages instead.
_flutter.loader.load();
