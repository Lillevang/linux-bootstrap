#!/usr/bin/env bash
set -euo pipefail

if ! command -v dnf >/dev/null 2>&1; then
  echo "❌ Fedora's dnf package manager not found. Kubernetes tool installation supports Fedora only."
  exit 1
fi

# Ensure prerequisites exist for installers and source builds.
sudo dnf install -y openssl git make

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Skaffold
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
chmod +x skaffold && sudo mv skaffold /usr/local/bin/

# k9s (build from source in ~/tools)
if ! command -v go >/dev/null 2>&1; then
  echo "❌ Go is required to build k9s from source, but was not found."
  exit 1
fi

k9s_repo_dir="$HOME/repos/tools/k9s"

if [ -d "$k9s_repo_dir/.git" ]; then
  git -C "$k9s_repo_dir" pull --ff-only
else
  rm -rf "$k9s_repo_dir"
  git clone --depth=1 https://github.com/derailed/k9s "$k9s_repo_dir"
fi

(
  cd "$k9s_repo_dir"
  make build
)

install -m 0755 "$k9s_repo_dir/execs/k9s" "$HOME/.local/bin/k9s"

echo "✅ k9s installed to $HOME/.local/bin/k9s"
