#!/usr/bin/env bash
set -e

echo "🔧 Installing base tools..."

if [ -x "$(command -v apt-get)" ]; then
  sudo apt-get update
  sudo apt-get install -y curl wget git zsh unzip htop fzf
elif [ -x "$(command -v dnf)" ]; then
  sudo dnf install -y curl wget git zsh unzip htop fzf
else
  echo "❌ Unsupported package manager. Please install tools manually."
  exit 1
fi

echo "✅ Tools installed."
