#!/usr/bin/env bash
set -euo pipefail

if ! command -v go >/dev/null 2>&1; then
  echo "Go is not installed, skipping updater"
  exit 0
fi

# Fetch the current version of the Go binary.
installed_version=$(go version | awk '{print $3}' | sed 's/^go//')

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
checker_script="$script_dir/check_go_update.py"

if [ ! -f "$checker_script" ]; then
  echo "Go updater checker script not found at $checker_script"
  exit 1
fi

output=$(python3 "$checker_script" "$installed_version")
read -r version download_link checksum <<<"$output"

if [ -z "$version" ]; then
  echo "Go is up to date"
  exit 0
fi

echo "New version available: $version"

wget -O go_new_version.tar.gz "$download_link"
echo "$checksum go_new_version.tar.gz" | sha256sum -c -

echo "New version valid, updating Go..."
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go_new_version.tar.gz
rm go_new_version.tar.gz
echo "Go updated to version $version"
