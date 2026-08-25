{{flutter_js}}
{{flutter_build_config}}

// Chrome sends focus/blur/visibilitychange while CanvasKit loads, before Dart
// main() can resize ChannelBuffers. Capture-phase stopImmediatePropagation
// delayed Debugger.enable (DWDS 5s timeout). Wrap Flutter's later listeners
// instead: drop those DOM events until WidgetsFlutterBinding is ready.
(function () {
  var ready = false;
  window.__degloorHoldLifecycle = function () {
    ready = false;
  };
  window.__degloorReleaseLifecycle = function () {
    ready = true;
  };
  function wrap(target) {
    var orig = target.addEventListener.bind(target);
    target.addEventListener = function (type, listener, options) {
      if (type === 'focus' || type === 'blur' || type === 'visibilitychange') {
        if (type === 'focus' && target === window && ready) {
          // New isolate after hot restart: engine re-binds before Dart main().
          ready = false;
        }
        var wrapped = function (event) {
          if (!ready) return;
          if (typeof listener === 'function') {
            return listener.call(this, event);
          }
          if (listener && typeof listener.handleEvent === 'function') {
            return listener.handleEvent(event);
          }
        };
        return orig(type, wrapped, options);
      }
      return orig(type, listener, options);
    };
  }
  wrap(window);
  wrap(document);
})();

_flutter.loader.load();
