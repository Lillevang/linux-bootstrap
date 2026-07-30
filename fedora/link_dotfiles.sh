#!/bin/bash

DOTFILES_DIR="$(pwd)/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"

mkdir -p "$BACKUP_DIR"

for file in "$DOTFILES_DIR"/.*; do
  [ -f "$file" ] || continue
  filename="$(basename "$file")"
  target="$HOME/$filename"

  if [ "$(readlink "$target" 2>/dev/null)" = "$file" ]; then
    echo "✅ $filename already linked"
    continue
  fi

  if [ -e "$target" ]; then
    echo "⚠️  Backing up $filename to $BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/"
  fi

  echo "🔗 Linking $filename"
  ln -s "$file" "$target"
done

# The linked .gitconfig has no global identity — it includeIf's these
# machine-local files, and useConfigOnly makes commits fail without them.
for identity in "$HOME/.gitconfig-personal" "$HOME/.gitconfig-work"; do
  if [ ! -f "$identity" ]; then
    echo "⚠️  Missing $identity — create it or commits will fail. See 'Git Identity' in the README."
  fi
done
