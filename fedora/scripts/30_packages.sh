#!/usr/bin/env bash
set -euo pipefail

FEDORA_VER="$(rpm -E %fedora)"
TASK_REPO_FILE="/etc/yum.repos.d/task-task.repo"

sudo dnf -y copr enable lihaohong/yazi

# go-task's official repo — Fedora's own go-task package names the binary
# go-task; this one installs it as plain `task`, matching Taskfile docs
if [ ! -f "$TASK_REPO_FILE" ]; then
  sudo tee "$TASK_REPO_FILE" >/dev/null <<EOF
[task-task]
name=task-task
baseurl=https://dl.cloudsmith.io/public/task/task/rpm/fedora/${FEDORA_VER}/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://dl.cloudsmith.io/public/task/task/gpg.046FD1186CA342F0.key
EOF
fi

sudo dnf -y install \
  git \
  gnome-tweaks \
  gnome-extensions-app \
  zsh \
  htop \
  btop \
  fzf \
  zoxide \
  yazi \
  helix \
  nodejs-npm \
  nodejs-bash-language-server \
  uv \
  ruff \
  make \
  just \
  task \
  jq \
  ShellCheck \
  shfmt \
  ripgrep \
  fd-find \
  bat \
  eza \
  gh \
  git-delta \
  yq \
  tree \
  direnv \
  duf \
  du-dust \
  procs \
  chezmoi \
  podman \
  podman-compose \
  buildah \
  skopeo \
  hyperfine \
  fastfetch \
  atuin
