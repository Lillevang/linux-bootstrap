#!/bin/bash

DOTFILES_DIR="$(pwd)/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"

mkdir -p "$BACKUP_DIR"

for file in "$DOTFILES_DIR"/.*; do
  [ -f "$file" ] || continue
  filename="$(basename "$file")"
  target="$HOME/$filename"
  
  if [ -e "$target" ]; then
    echo "⚠️  Backing up $filename to $BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/"
  fi

  echo "🔗 Linking $filename"
  ln -s "$file" "$target"
done
