# Linux Bootstrap

A bootstrap toolkit for setting up a fresh Fedora environment (workstation, VM, or WSL) with core CLI tools, languages, shell customizations, and dotfile links.

## Scope

This project currently targets Fedora systems that use `dnf`.

## What the bootstrap does

The bootstrap runs a sequence of modular scripts:

- Creates a base folder structure under `$HOME`
- Installs core tools (for example: git, curl, zsh, ripgrep)
- Installs language toolchains (Node via nvm, Go, .NET, Rust, Crystal)
- Installs Helix and selected language servers
- Installs Kubernetes tooling (kubectl, Helm, Skaffold, k9s)
- Installs Oh My Zsh, Powerlevel10k, and common plugins
- Symlinks dotfiles into `$HOME`
- Checks for Go updates

## One-time setup

Before first use on a machine:

1. Generate an SSH key

   ```bash
   ssh-keygen -t ed25519 -C "your@email.com"
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

2. Copy your public key

   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

3. Add it to GitHub: <https://github.com/settings/ssh/new>
4. Clone the repository

   ```bash
   git clone git@github.com:<your-username>/linux-bootstrap.git
   cd linux-bootstrap
   ```

## Usage

Run the full bootstrap:

```bash
./install.sh
```

If a step fails, review the summary output and rerun that script directly from `scripts/` after fixing the underlying issue.

## Script layout

- `install.sh` - Orchestrates all setup steps and prints a summary
- `scripts/create_folders.sh` - Creates standard directories
- `scripts/install_tools.sh` - Installs base Fedora tooling
- `scripts/install_languages.sh` - Installs language runtimes and toolchains
- `scripts/install_editors.sh` - Installs Helix and language server tooling
- `scripts/install_kube_tools.sh` - Installs Kubernetes CLI tools
- `scripts/install_oh_my_zsh.sh` - Installs shell framework, theme, and plugins
- `link_dotfiles.sh` - Symlinks dotfiles into `$HOME` (with backup)
- `scripts/go-updater/` - Go version check/update utility

## Tested on

- Fedora 44

## TODO

- Address Fedora 44 issues:
  - Crystal install path/repository reliability
  - Language servers currently installed via `dnf` that should likely move to `npm` and/or `pipx`
- Add Helix configuration files
- Add a Yazi install script that:
  - Clones the required Yazi repository/repositories
  - Builds with Cargo
  - Installs the binary in the expected location used by this bootstrap
