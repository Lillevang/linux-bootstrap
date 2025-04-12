#!/bin/bash
set -euo pipefail

REPO_DIR="$HOME/repos/tools/k9s"
INSTALL_DIR="/usr/local/k9s/bin"
EXECUTABLE="k9s"
EXEC_PATH="$INSTALL_DIR/$EXECUTABLE"

# Detect latest release version
echo "🔍 Fetching latest release tag from GitHub..."
LATEST_TAG=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r .tag_name)
LATEST_TAG_STRIPPED=$(echo "$LATEST_TAG" | sed 's/^v//')
echo "➡️  Latest version: $LATEST_TAG"

if command -v "$EXECUTABLE" >/dev/null 2>&1; then
  CURRENT_VERSION=$("$EXECUTABLE" version -s | grep -i '^Version' | awk '{print $2}' | sed 's/^v//')
  echo "📦 Installed version: $CURRENT_VERSION"

  if [[ "$CURRENT_VERSION" == "$LATEST_TAG_STRIPPED" ]]; then
    echo "✅ Already up-to-date!"
    exit 0
  fi
else
  echo "ℹ️  No existing installation detected. Proceeding with fresh install..."
fi

echo "📁 Navigating to $REPO_DIR..."
cd "$REPO_DIR"

echo "🌐 Fetching latest tags from git..."
git fetch --tags

echo "🔄 Checking out tag $LATEST_TAG..."
git checkout "$LATEST_TAG"

echo "🔨 Building..."
make build

echo "📤 Installing to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

if [ -w "$INSTALL_DIR" ]; then
  cp "$REPO_DIR/execs/k9s" "$EXEC_PATH"
else
  echo "🔐 Need sudo to write to $INSTALL_DIR"
  sudo cp "$REPO_DIR/execs/k9s" "$EXEC_PATH"
fi

echo "🎉 Done! K9s updated to $LATEST_TAG"
