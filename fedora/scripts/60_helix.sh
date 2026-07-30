#!/usr/bin/env bash
set -euo pipefail

# Symlink helix configs from dotfiles/ into ~/.config/helix (they aren't
# plain $HOME dotfiles, so link_dotfiles.sh can't handle them)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../dotfiles" && pwd)"
HELIX_DIR="$HOME/.config/helix"
BACKUP_DIR="$HOME/.dotfiles_backup"

mkdir -p "$HELIX_DIR"

for name in config.toml languages.toml; do
  src="$DOTFILES_DIR/$name"
  target="$HELIX_DIR/$name"

  [ "$(readlink "$target" 2>/dev/null)" = "$src" ] && continue

  if [ -e "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/helix_$name"
  fi

  ln -s "$src" "$target"
done
