#!/usr/bin/env bash
# Serve without attaching Chrome's debugger. Use when -d chrome still times out.
set -euo pipefail
cd "$(dirname "$0")/.."
exec flutter run -d web-server \
  --web-hostname 127.0.0.1 \
  --web-port "${WEB_PORT:-8080}" \
  "$@"
