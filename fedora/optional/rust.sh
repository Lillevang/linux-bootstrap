#!/usr/bin/env bash
set -euo pipefail

# lldb provides lldb-dap, the debug adapter helix expects for rust and zig
sudo dnf -y install \
  rust \
  cargo \
  rustfmt \
  clippy \
  rust-analyzer \
  lldb
