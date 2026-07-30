#!/usr/bin/env bash
set -euo pipefail

# Runs the optional units listed in this machine's manifest
# (fedora/machines/<hostname>.conf): one unit name per line, '#' comments.
# Units are self-contained and idempotent — they can always be run
# directly instead: bash optional/<unit>.sh
OPTIONAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${1:-$OPTIONAL_DIR/../machines/$(hostname).conf}"

if [ ! -f "$MANIFEST" ]; then
  echo "No manifest at $MANIFEST — create one (see fedora/machines/) or pass a path." >&2
  exit 1
fi

while IFS= read -r line; do
  unit="${line%%#*}"
  unit="${unit//[[:space:]]/}"
  [ -n "$unit" ] || continue

  if [ ! -f "$OPTIONAL_DIR/$unit.sh" ]; then
    echo "Unknown unit '$unit' in $MANIFEST" >&2
    exit 1
  fi

  echo "── optional: $unit"
  bash "$OPTIONAL_DIR/$unit.sh"
done <"$MANIFEST"
