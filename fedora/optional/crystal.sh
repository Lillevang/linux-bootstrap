#!/usr/bin/env bash
set -euo pipefail

FEDORA_VER="$(rpm -E %fedora)"
LOCAL_BIN="$HOME/.local/bin"

# crystal and shards ship via Terra (repos.fyralabs.com), not Fedora proper
if ! rpm -q terra-release >/dev/null 2>&1; then
  sudo dnf -y install \
    --repofrompath "terra,https://repos.fyralabs.com/terra${FEDORA_VER}" \
    --setopt="terra.gpgkey=https://repos.fyralabs.com/terra${FEDORA_VER}/key.asc" \
    terra-release
fi

sudo dnf -y install \
  crystal \
  shards

mkdir -p "$LOCAL_BIN"

# crystalline (LSP): prebuilt static binary from GitHub releases
if ! command -v crystalline >/dev/null 2>&1; then
  curl -fsSL "https://github.com/elbywan/crystalline/releases/latest/download/crystalline_x86_64-unknown-linux-musl.gz" |
    gunzip >"$LOCAL_BIN/crystalline"
  chmod +x "$LOCAL_BIN/crystalline"
fi

# ameba (linter): publishes no binaries — build from source
if ! command -v ameba >/dev/null 2>&1; then
  TMP="$(mktemp -d)"
  git clone --quiet --depth 1 https://github.com/crystal-ameba/ameba.git "$TMP"
  (cd "$TMP" && shards build --release ameba)
  cp "$TMP/bin/ameba" "$LOCAL_BIN/ameba"
  rm -rf "$TMP"
fi
