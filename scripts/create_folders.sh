#!/usr/bin/env bash
set -euo pipefail

echo "📁 Creating standard folder structure..."

mkdir -p ~/repos/{tools,personal,work}
mkdir -p ~/tools
mkdir -p ~/.local/bin
sudo mkdir -p /usr/local/bin

echo "✅ Folder setup complete."
