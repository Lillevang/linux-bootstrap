#!/usr/bin/env bash
set -euo pipefail

DNF_CONF="/etc/dnf/dnf.conf"

ensure_kv() {
  local key="$1"
  local value="$2"

  if sudo grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$DNF_CONF"; then
    sudo sed -i "s|^[[:space:]]*${key}[[:space:]]*=.*|${key}=${value}|" "$DNF_CONF"
  else
    echo "${key}=${value}" | sudo tee -a "$DNF_CONF" >/dev/null
  fi
}

ensure_kv "fastestmirror" "True"
ensure_kv "max_parallel_downloads" "10"
