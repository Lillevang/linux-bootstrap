#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing base tools..."

if [ -x "$(command -v dnf)" ]; then
  # dnf5 requires plugins package for config-manager.
  sudo dnf install -y dnf-plugins-core

  sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg

  # dnf4 and dnf5 use different config-manager syntax.
  if sudo dnf config-manager --help 2>/dev/null | grep -q -- "--add-repo"; then
    sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
  else
    sudo dnf config-manager addrepo --from-repofile=https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
  fi

  sudo dnf install -y curl wget git zsh unzip htop fzf gawk openssl sublime-merge
else
  echo "❌ Fedora's dnf package manager not found. This bootstrap currently supports Fedora only."
  exit 1
fi

echo "✅ Tools installed."
