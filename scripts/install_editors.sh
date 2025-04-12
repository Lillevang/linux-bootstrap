# Install Helix
curl -LO https://github.com/helix-editor/helix/releases/latest/download/helix-23.10-x86_64.AppImage
chmod +x helix-*.AppImage
sudo mv helix-*.AppImage /usr/local/bin/hx

# Or install from GitHub tarball
hx --grammar fetch
