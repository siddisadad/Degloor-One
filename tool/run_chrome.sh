#!/usr/bin/env bash
# Chrome DWDS AppInspector evaluates dartDevEmbedder.debugger.extensionNames
# in JS context 1. After a reload that context is gone, so Runtime.evaluate
# fails with "Cannot find context with specified id". Do not launch -d chrome.
exec "$(dirname "$0")/run_web.sh" "$@"
