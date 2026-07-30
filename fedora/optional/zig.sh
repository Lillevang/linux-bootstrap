#!/usr/bin/env bash
set -euo pipefail

LOCAL_BIN="$HOME/.local/bin"

sudo dnf -y install \
  zig \
  lldb

# zls must match the installed zig version; releases.zigtools.org picks
# the right build for us
if ! command -v zls >/dev/null 2>&1; then
  TARBALL="$(curl -fsSL "https://releases.zigtools.org/v1/zls/select-version?zig_version=$(zig version)&compatibility=only-runtime" |
    jq -re '."x86_64-linux".tarball')"
  mkdir -p "$LOCAL_BIN"
  curl -fsSL "$TARBALL" | tar -xJ -C "$LOCAL_BIN" zls
fi
