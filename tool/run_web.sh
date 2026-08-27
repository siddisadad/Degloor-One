#!/usr/bin/env bash
# Serve without attaching Chrome's debugger. AppInspector's Runtime.evaluate
# (dartDevEmbedder.debugger.extensionNames, contextId 1) only runs on -d chrome.
set -euo pipefail
cd "$(dirname "$0")/.."
exec flutter run -d web-server \
  --web-hostname 127.0.0.1 \
  --web-port "${WEB_PORT:-8080}" \
  --no-web-resources-cdn \
  "$@"
