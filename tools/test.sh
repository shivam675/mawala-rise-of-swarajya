#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
godot_bin="${1:-godot}"
test_log="$(mktemp)"
trap 'rm -f "$test_log"' EXIT
for test_scene in tests/smoke.gd tests/journey.gd; do
  "$godot_bin" --headless --fixed-fps 60 --path . --script "$test_scene" --quit-after 2200 > "$test_log" 2>&1
  cat "$test_log"
  if rg -q 'SCRIPT ERROR|ERROR:|Assertion failed' "$test_log" || ! rg -q '^PASS:' "$test_log"; then
    exit 1
  fi
done
