#!/usr/bin/env bash
set -euo pipefail

# Terra (repos.fyralabs.com) provides packages missing from Fedora proper,
# e.g. crystal. Must run before 30_packages.sh.
FEDORA_VER="$(rpm -E %fedora)"

if ! rpm -q terra-release >/dev/null 2>&1; then
  sudo dnf -y install \
    --repofrompath "terra,https://repos.fyralabs.com/terra${FEDORA_VER}" \
    --setopt="terra.gpgkey=https://repos.fyralabs.com/terra${FEDORA_VER}/key.asc" \
    terra-release
fi
