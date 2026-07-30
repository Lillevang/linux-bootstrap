#!/usr/bin/env bash
set -euo pipefail

sudo dnf -y copr enable lihaohong/yazi

sudo dnf -y install \
  git \
  gnome-tweaks \
  gnome-extensions-app \
  zsh \
  htop \
  fzf \
  autojump \
  autojump-zsh \
  yazi \
  crystal \
  zig \
  helix
