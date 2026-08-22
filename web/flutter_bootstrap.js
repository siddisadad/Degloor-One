{{flutter_js}}
{{flutter_build_config}}

// Swallow window focus/blur until Dart binds flutter/lifecycle. Chrome fires
// those while CanvasKit loads; the engine forwards them and ChannelBuffers
// prints "message ... discarded before it could be handled".
(function () {
  var hold = true;
  function swallow(event) {
    if (hold) {
      event.stopImmediatePropagation();
    }
  }
  window.addEventListener('focus', swallow, true);
  window.addEventListener('blur', swallow, true);
  document.addEventListener('visibilitychange', swallow, true);
  window.__degloorReleaseLifecycle = function () {
    hold = false;
  };
})();

_flutter.loader.load();
