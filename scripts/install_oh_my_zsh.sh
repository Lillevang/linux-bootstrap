#!/usr/bin/env bash
set -euo pipefail

echo "🐚 Installing Oh My Zsh..."

if ! command -v zsh >/dev/null 2>&1; then
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y zsh
  else
    echo "❌ zsh is required but dnf is unavailable."
    exit 1
  fi
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh already installed."
fi

echo "🎨 Installing powerlevel10k..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

echo "🔌 Installing plugins..."
for plugin in \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  zsh-completions \
  zsh-history-substring-search; do
  target="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin"
  if [ ! -d "$target" ]; then
    git clone "https://github.com/zsh-users/$plugin" "$target"
  fi
done

echo "🧲 Installing autojump..."
if [ -x "$(command -v dnf)" ]; then
  sudo dnf install -y autojump
else
  echo "⚠️  Skipping autojump install because dnf is unavailable (Fedora-only step)."
fi
