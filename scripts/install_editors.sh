#!/usr/bin/env bash
set -euo pipefail

if ! command -v dnf >/dev/null 2>&1; then
  echo "❌ Fedora's dnf package manager not found. Editor installation supports Fedora only."
  exit 1
fi

echo "📝 Installing Helix..."
sudo dnf install -y helix

# Ensure npm is available for language servers that are not consistently packaged on Fedora.
if [ -z "${NVM_DIR:-}" ]; then
  export NVM_DIR="$HOME/.nvm"
fi
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
fi

# Prefer distro packages where stable, then fall back to language-native installers.
echo "🧩 Installing common LSPs..."
sudo dnf install -y \
  rust-analyzer \
  gopls \
  python3-pylsp \
  clang-tools-extra

if command -v npm >/dev/null 2>&1; then
  npm install -g vscode-langservers-extracted yaml-language-server bash-language-server
else
  echo "⚠️  npm not found; skipping npm-based LSP servers."
fi

if command -v cargo >/dev/null 2>&1; then
  cargo install --locked marksman || true
else
  echo "⚠️  cargo not found; skipping marksman installation."
fi

echo "🧪 Verifying Helix installation..."
hx --health
