#!/usr/bin/env bash
set -euo pipefail

# Workstation-only extras. Fedora Cloud/Server installs deliberately skip this.
if ! rpm -q gnome-shell >/dev/null 2>&1; then
  exit 0
fi

FEDORA_VER="$(rpm -E %fedora)"

sudo dnf -y copr enable scottames/ghostty

sudo dnf -y install   ghostty   sway   jetbrains-mono-fonts-all   gnome-shell-extension-forge   gnome-shell-extension-blur-my-shell   gnome-shell-extension-just-perfection

if command -v flatpak >/dev/null 2>&1; then
  flatpak remote-add --user --if-not-exists     flathub https://flathub.org/repo/flathub.flatpakrepo

  flatpak install --user -y flathub     com.mattjakeman.ExtensionManager     org.localsend.localsend_app
fi

# Espanso's Fedora Wayland package is published through Terra.
if ! rpm -q terra-release >/dev/null 2>&1; then
  sudo dnf -y install     --repofrompath "terra,https://repos.fyralabs.com/terra${FEDORA_VER}"     --setopt="terra.gpgkey=https://repos.fyralabs.com/terra${FEDORA_VER}/key.asc"     terra-release
fi

ESPANSO_PACKAGE="espanso-wayland"
if [ "${XDG_SESSION_TYPE:-wayland}" = "x11" ]; then
  ESPANSO_PACKAGE="espanso-x11"
fi

sudo dnf -y install "$ESPANSO_PACKAGE"

# Wayland Espanso needs this capability to access input/uinput devices.
if [ "$ESPANSO_PACKAGE" = "espanso-wayland" ] && command -v espanso >/dev/null 2>&1; then
  sudo setcap "cap_dac_override+p" "$(command -v espanso)"
fi
