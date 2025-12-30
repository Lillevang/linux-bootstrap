#!/usr/bin/env bash
set -e

echo "🔧 Installing base tools..."

if [ -x "$(command -v dnf)" ]; then
  sudo dnf install -y curl wget git unzip htop fzf
else
  echo "❌ Fedora's dnf package manager not found. This bootstrap currently supports Fedora only."
  exit 1
fi

echo "✅ Tools installed."
