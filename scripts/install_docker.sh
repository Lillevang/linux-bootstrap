# Use Docker on Ubuntu
if [ -x "$(command -v apt)" ]; then
  sudo apt install -y docker.io
  sudo systemctl enable docker --now
# Podman on Fedora
elif [ -x "$(command -v dnf)" ]; then
  sudo dnf install -y podman
fi
