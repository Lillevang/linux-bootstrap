#!/usr/bin/env bash
set -euo pipefail

if ! command -v dnf >/dev/null 2>&1; then
  echo "❌ Fedora's dnf package manager not found. Editor installation supports Fedora only."
  exit 1
fi

echo "📝 Installing Helix and common LSPs via dnf..."
sudo dnf install -y helix \
  rust-analyzer \
  gopls \
  python3-pylsp \
  clang-tools-extra \
  yaml-language-server \
  marksman

echo "🧪 Verifying Helix installation..."
hx --health
