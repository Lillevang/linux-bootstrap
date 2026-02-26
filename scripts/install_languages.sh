#!/usr/bin/env bash
set -euo pipefail

# NVM / Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"

# WSL setups can inherit a Windows npm prefix from a global npmrc.
# This breaks npm inside Linux; remove any effective prefix before installing.
npm config delete prefix >/dev/null 2>&1 || true
unset npm_config_prefix NPM_CONFIG_PREFIX PREFIX || true

nvm install --lts

# Ensure running on Fedora (dnf present)
if ! [ -x "$(command -v dnf)" ]; then
  echo "❌ Fedora's dnf package manager not found. Language installation supports Fedora only."
  exit 1
fi

# Go (system)
if ! command -v go >/dev/null 2>&1; then
  sudo dnf install -y golang
fi

# Rust
curl https://sh.rustup.rs -sSf | sh -s -- -y

# Crystal
curl -fsSL https://crystal-lang.org/install.sh | bash
