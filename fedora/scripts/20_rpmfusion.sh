#!/usr/bin/env bash
set -euo pipefail

# Enable RPM Fusion repos for current Fedora Version
FEDORA_VER="$(rpm -E %fedora)"

sudo dnf -y install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"

sudo dnf -y makecache
