#!/usr/bin/env bash
set -euo pipefail

# Sublime Merge is the configured git mergetool (see dotfiles/.gitconfig)
REPO_FILE="/etc/yum.repos.d/sublime-text.repo"

sudo rpm -v --import "https://download.sublimetext.com/sublimehq-rpm-pub.gpg"

if [ ! -f "$REPO_FILE" ]; then
  sudo dnf config-manager addrepo --from-repofile="https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo"
fi

sudo dnf -y install sublime-merge
