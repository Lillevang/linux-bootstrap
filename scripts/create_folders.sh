#!/usr/bin/env bash
set -e

echo "📁 Creating standard folder structure..."

mkdir -p ~/repos/{tools, personal, work}
mkdir -p ~/.local/bin
sudo mkdir -p /usr/local/bin /usr/local/go /usr/local/k9s/bin

echo "✅ Folder setup complete."
