#!/usr/bin/env bash
set -euo pipefail

# Python is a base stable: uv and ruff come from dnf (30_packages.sh);
# pylsp is the LSP half of helix's python defaults (ruff is the other)
command -v pylsp >/dev/null 2>&1 || uv tool install python-lsp-server
