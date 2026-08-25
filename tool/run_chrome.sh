#!/usr/bin/env bash
# Chrome 111+ rejects DWDS's debugger websocket unless this origin is allowed.
# Without it, WebkitDebugger.enable hits the 5s timeout and flutter run dies.
set -euo pipefail
cd "$(dirname "$0")/.."
exec flutter run -d chrome \
  --web-hostname 127.0.0.1 \
  --web-browser-flag=--remote-allow-origins=* \
  --web-browser-flag=--disable-dev-shm-usage \
  "$@"
