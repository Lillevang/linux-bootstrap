#!/usr/bin/env bash
set -euo pipefail

OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_CUSTOM="$OMZ_DIR/custom"
OMZ_INSTALLER="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

clone_if_missing() {
  local url="$1"
  local dest="$2"

  [ -d "$dest" ] || git clone --depth 1 "$url" "$dest"
}

if [ ! -d "$OMZ_DIR" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL "$OMZ_INSTALLER")"
fi

clone_if_missing "https://github.com/romkatv/powerlevel10k.git" \
  "$OMZ_CUSTOM/themes/powerlevel10k"
clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions.git" \
  "$OMZ_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
  "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_missing "https://github.com/zsh-users/zsh-completions.git" \
  "$OMZ_CUSTOM/plugins/zsh-completions"
clone_if_missing "https://github.com/zsh-users/zsh-history-substring-search.git" \
  "$OMZ_CUSTOM/plugins/zsh-history-substring-search"
clone_if_missing "https://github.com/unixorn/fzf-zsh-plugin.git" \
  "$OMZ_CUSTOM/plugins/fzf-zsh-plugin"

# sudo chsh instead of plain chsh: root isn't asked for the user's
# password, so this works unattended (VM tests, future orchestrator)
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  sudo chsh -s "$(command -v zsh)" "$USER"
fi
