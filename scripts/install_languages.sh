#!/usr/bin/env bash
set -e

# NVM / Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
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

# asdf (installed via Go)
ASDF_VERSION="${ASDF_VERSION:-0.18.0}"
go install "github.com/asdf-vm/asdf/cmd/asdf@v${ASDF_VERSION}"
ASDF_BIN="$(go env GOBIN)"
if [ -z "$ASDF_BIN" ]; then
  ASDF_BIN="$(go env GOPATH)/bin"
fi
export PATH="${PATH}:${ASDF_BIN}"

# Rust
curl https://sh.rustup.rs -sSf | sh -s -- -y

# Crystal
curl -fsSL https://crystal-lang.org/install.sh | bash

# Elixir
asdf plugin add elixir
asdf install elixir latest
asdf global elixir latest
