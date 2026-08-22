{{flutter_js}}
{{flutter_build_config}}

// HTML renderer was removed in Flutter 3.29. Use the default CanvasKit/Skwasm
// engine so initializeEngine does not stall on a dead `renderer: "html"` option
// while Chrome focus/blur floods flutter/lifecycle.
_flutter.loader.load();
