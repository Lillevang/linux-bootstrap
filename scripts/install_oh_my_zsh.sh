#!/usr/bin/env bash
set -e

echo "🐚 Installing Oh My Zsh..."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh already installed."
fi

echo "🎨 Installing powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

echo "🔌 Installing plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-completions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"
git clone https://github.com/zsh-users/zsh-history-substring-search \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"

echo "🧲 Installing autojump..."
if [ -x "$(command -v dnf)" ]; then
  sudo dnf install -y autojump
else
  echo "⚠️  Skipping autojump install because dnf is unavailable (Fedora-only step)."
fi
