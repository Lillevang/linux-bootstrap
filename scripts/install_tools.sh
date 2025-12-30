#!/usr/bin/env bash
set -e

echo "🔧 Installing base tools..."

if [ -x "$(command -v dnf)" ]; then
  sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
  sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
  sudo dnf install -y curl wget git zsh unzip htop fzf sublime-merge
else
  echo "❌ Fedora's dnf package manager not found. This bootstrap currently supports Fedora only."
  exit 1
fi

echo "✅ Tools installed."
