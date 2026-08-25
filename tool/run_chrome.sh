#!/usr/bin/env bash
# Chrome 111+ rejects DWDS's debugger websocket unless this origin is allowed.
# Without it, WebkitDebugger.enable hits the 5s timeout and flutter run dies.
#
# Chrome 148 also discards a background renderer. That destroys JS context 1,
# so AppInspector's Runtime.evaluate (dartDevEmbedder.debugger.extensionNames)
# fails with "Cannot find context with specified id". Keep the tab's renderer
# and skip BFCache/prerender so the Dart context stays the one DWDS cached.
#
# Serve Chrome debug on 8090 so it never shares 8080 with web-server. Two
# flutter run sessions on the same origin recycle context 1 and trip AppInspector.
set -euo pipefail
cd "$(dirname "$0")/.."
exec flutter run -d chrome \
  --web-hostname 127.0.0.1 \
  --web-port "${WEB_PORT:-8090}" \
  --no-web-resources-cdn \
  --web-browser-flag=--remote-allow-origins=* \
  --web-browser-flag=--disable-dev-shm-usage \
  --web-browser-flag=--disable-renderer-backgrounding \
  --web-browser-flag=--disable-backgrounding-occluded-windows \
  --web-browser-flag=--disable-features=BackForwardCache,Prerender2 \
  "$@"
