#!/usr/bin/env bash
set -euo pipefail

# kubectl comes from the upstream Kubernetes repo, pinned to the current
# stable minor at install time; helm and k9s are in Fedora proper
K8S_REPO_FILE="/etc/yum.repos.d/kubernetes.repo"

if [ ! -f "$K8S_REPO_FILE" ]; then
  K8S_MINOR="$(curl -fsSL https://dl.k8s.io/release/stable.txt | grep -oE '^v[0-9]+\.[0-9]+')"
  sudo tee "$K8S_REPO_FILE" >/dev/null <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/rpm/repodata/repomd.xml.key
EOF
fi

sudo dnf -y install \
  kubectl \
  helm \
  k9s
