# 🐧 Linux Bootstrap

Bootstrap a fresh Fedora machine (laptop, WSL, VM, etc.) with essential tools, languages, and dotfiles. This bootstrap currently targets dnf-based Fedora systems only.

---

## ✅ What It Does

- Installs your preferred tools (curl, git, zsh, etc.)
- Installs programming languages (Python, Go, etc.)
- Installs Oh My Zsh and your `.zshrc`
- Symlinks all your dotfiles into `$HOME`
- Optionally installs GUI tools if running on a full Linux desktop

---

## 🧍 Manual Setup (One-Time Per Machine)

Before running the bootstrap script, you need to:

1. **Generate an SSH key:**

    ```bash
    ssh-keygen -t ed25519 -C "your@email.com"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    ```

2. **Copy the public key:**

    ```bash
    cat ~/.ssh/id_ed25519.pub
    ```

3. **Add it to your GitHub account:**

    - Go to: https://github.com/settings/ssh/new
    - Paste the public key

4. **Clone this repo:**

    ```bash
    git clone git@github.com:<your-username>/linux-bootstrap.git
    cd linux-bootstrap
    ```

5. **Run the bootstrap:**

    ```bash
    ./install.sh
    ```

---

## 🧪 Tested On

- Fedora (Workstation/Server)

---

## 📦 Components

See `scripts/` folder for modular installers:
- `install_tools.sh` — core tools
- `install_languages.sh` — Python, Go, etc.
- `install_oh_my_zsh.sh` — shell setup
- `link_dotfiles.sh` — symlinks configs from `dotfiles/`

---

## 🗂️ Dotfiles

Your personal dotfiles live under `dotfiles/` and get symlinked to `$HOME`.

---

## ✨ Ideas for the Future

- Detect GUI vs CLI-only environments
- Install GUI apps conditionally
- Add WSL-specific or Arch-specific setup
