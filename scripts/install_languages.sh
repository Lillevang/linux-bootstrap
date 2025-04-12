# NVM / Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm install --lts

# Python (latest)
if [ -x "$(command -v apt)" ]; then
  sudo apt install -y python3 python3-pip
elif [ -x "$(command -v dnf)" ]; then
  sudo dnf install -y python3 python3-pip
fi

# Java (Temurin via asdf or system)
sudo apt install -y openjdk-21-jdk || sudo dnf install java-21-openjdk-devel

# Rust
curl https://sh.rustup.rs -sSf | sh -s -- -y

# Crystal
curl -fsSL https://crystal-lang.org/install.sh | bash

# Elixir
asdf plugin add elixir
asdf install elixir latest
asdf global elixir latest
