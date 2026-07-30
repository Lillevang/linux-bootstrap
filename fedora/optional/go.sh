#!/usr/bin/env bash
set -euo pipefail

# Everything `hx --health go` wants: gopls + golangci-lint-lsp + dlv.
# golangci-lint-langserver isn't packaged anywhere, so it's a go install.
LOCAL_BIN="$HOME/.local/bin"

sudo dnf -y install \
  golang \
  gopls \
  delve \
  golangci-lint

command -v golangci-lint-langserver >/dev/null 2>&1 ||
  GOBIN="$LOCAL_BIN" go install github.com/nametake/golangci-lint-langserver@latest
