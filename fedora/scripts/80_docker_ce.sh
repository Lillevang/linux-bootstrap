# 1. Remove the podman docker-shim if present (only real conflict)
rpm -q podman-docker && sudo dnf remove -y podman-docker

# 2. Install docker-ce from Docker's repo
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 3. Start + enable, add yourself to the docker group
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker   # or log out/in

# 4. Make sure nothing redirects docker to podman
env | grep -i docker    # DOCKER_HOST must be unset; if set, purge from shell rc

# 5. Verify both
docker run --rm hello-world
podman ps
