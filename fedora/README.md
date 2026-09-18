# 🐧 Fedora Bootstrap

Bootstrap a fresh Fedora machine with numbered setup scripts and dotfiles. Targets dnf-based Fedora (Workstation) only; other distros may get their own top-level directory later.

---

## 🧍 Manual Setup (One-Time Per Machine)

Before running anything, you need to:

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
    cd linux-bootstrap/fedora
    ```

---

## 🚀 Usage

There is no orchestrator yet (one is planned). Run the steps in numeric order from inside `fedora/`:

```bash
bash scripts/00_dirs.sh        # create ~/repos and ~/.local/bin
bash scripts/10_dnf_tuning.sh  # dnf.conf: fastest mirror, parallel downloads
bash scripts/20_rpmfusion.sh   # enable RPM Fusion free + nonfree
bash scripts/30_packages.sh    # base package set: shell/editor/dev, Podman stack + productivity CLI tools
bash scripts/35_workstation.sh # Workstation-only: Ghostty, GNOME polish, Sway, font, Flatpaks, Espanso
bash scripts/40_multimedia.sh  # multimedia group (needs RPM Fusion first)
bash scripts/50_ohmyzsh.sh     # Oh My Zsh + powerlevel10k + plugins, chsh to zsh
bash scripts/55_python.sh      # pylsp via uv tool (python is a base stable)
bash scripts/60_helix.sh       # symlink helix configs into ~/.config/helix
bash scripts/70_sublime_merge.sh # Sublime Merge (the mergetool set in .gitconfig)
bash link_dotfiles.sh          # symlink dotfiles/ into $HOME
```

Notes:

- Steps 10–40 and 70 need sudo. `35_workstation.sh` exits immediately on non-GNOME Fedora installs, so the Cloud VM test remains lean. 50/55/60 are user-scope (50 uses sudo only for `chsh`).
- Order matters: `20_rpmfusion.sh` must run before `40_multimedia.sh`, and `30_packages.sh` before 50/55/60 (they need git, uv, helix).
- `link_dotfiles.sh` must be run from inside `fedora/` — it resolves `dotfiles/` relative to the current directory. Existing files are backed up to `~/.dotfiles_backup` before linking; already-correct symlinks are skipped.
- The kubectl helpers in `.zshrc` and the NVM block only activate when those tools are installed, so the shared dotfiles work on machines with or without the optional units below.
- The shell config enables eza/bat/btop/duf/dust/procs helpers plus fuzzy Git/Kubernetes selectors when their commands are present.
- Podman is the default container stack (`podman`, `podman-compose`, `buildah`, `skopeo`). Docker CE is intentionally not installed.
- `mise` is deliberately not wired in yet; NVM remains the active Node manager until that migration is done.

---

## 🖥️ Workstation extras

`scripts/35_workstation.sh` is intentionally GNOME Workstation-specific. It installs:

- Ghostty (via the scottames COPR)
- Sway
- JetBrains Mono
- Forge, Blur My Shell, and Just Perfection GNOME extensions
- Extension Manager and LocalSend from Flathub
- Espanso from Terra, choosing the Wayland package by default and X11 when the current session reports X11

**Clipboard History** (SUPERCILEX) is still installed through Extension Manager rather than pinned in the bootstrap, because GNOME extension releases track shell versions independently.

After installing Espanso for the first time, register/start its user service from a graphical session:

```bash
espanso service register
espanso start
```

The existing symlink-based dotfile setup remains authoritative. `chezmoi` is installed as a useful tool, but the bootstrap does not migrate dotfile ownership to it yet.

---

## 🧩 Optional Units (per-machine)

The base above gives a fully working machine with zero project-specific toolchains. Everything else lives in `optional/` as self-contained, idempotent unit scripts:

| Unit | Installs |
|------|----------|
| `kube` | kubectl (upstream repo, stable minor), helm, k9s |
| `go` | golang, gopls, delve, golangci-lint (+ its language server) |
| `rust` | rust, cargo, rustfmt, clippy, rust-analyzer, lldb (lldb-dap) |
| `zig` | zig, zls (version-matched via releases.zigtools.org), lldb |
| `crystal` | Terra repo, crystal, shards, crystalline, ameba (built from source) |

Each machine declares its units in a committed manifest, `machines/<hostname>.conf` (one unit per line, `#` comments). Apply with:

```bash
bash optional/run.sh              # reads machines/$(hostname).conf
bash optional/run.sh path/to.conf # or an explicit manifest
bash optional/kube.sh             # or à la carte, any single unit
```

New machine: copy an existing conf, prune it, commit. Adding a tool later is a one-line diff plus a re-run — the repo stays the record of what every machine has.

**Definition of done for a language unit:** `hx --health <language>` is all green (LSP, debug adapter, formatter). `dotfiles/languages.toml` holds the overrides that make that contract honest (e.g. crystal is pinned to crystalline because helix's default `ameba-ls` has never shipped).

---

## 🧪 Testing

`test/fedora_vm_test.sh` (repo root) boots a **clean Fedora Cloud VM** with plain qemu+KVM (no libvirt setup needed), copies the local working tree in — uncommitted changes included — runs every numbered step plus `link_dotfiles.sh`, and then runs a battery of verification checks (login shell, symlinks, installed tools, enabled repos).

```bash
bash test/fedora_vm_test.sh              # base run; prints RESULT: PASS/FAIL, destroys VM
OPTIONAL=all bash test/fedora_vm_test.sh # also run every optional unit + hx --health checks
KEEP=1 bash test/fedora_vm_test.sh       # same, but leaves the VM running
bash test/fedora_vm_test.sh ssh          # shell into a kept VM
```

The ~700MB cloud image is cached in `~/.cache/linux-bootstrap-vmtest/` after the first run; every run boots a fresh disk overlay, so the VM is always pristine. Boot messages land in `console.log` next to the cache if a run hangs before ssh comes up.

---

## 🗂️ Dotfiles

Personal dotfiles live under `dotfiles/` and get symlinked into `$HOME` by `link_dotfiles.sh`. The Helix configs (`config.toml`, `languages.toml`) live in `~/.config/helix/` instead and are symlinked by `60_helix.sh`.

---

## 🪪 Git Identity (per-machine, not tracked)

The tracked `dotfiles/.gitconfig` sets **no global name/email**. Identity comes from `includeIf` blocks keyed on repo location, and `user.useConfigOnly = true` makes commits in unmatched repos fail loudly instead of silently using the wrong identity.

The included files are machine-local **on purpose** (the work one may carry client-specific details) and must be created by hand on each new machine:

```ini
# ~/.gitconfig-personal
[user]
    name = Your Name
    email = your@personal-email.com
    signingKey = ~/.ssh/id_ed25519.pub
```

```ini
# ~/.gitconfig-work
[user]
    name = Your Name
    email = your@work-email.com
    signingKey = ~/.ssh/id_ed25519.pub
```

Which file applies is decided by the `includeIf "gitdir:..."` rules at the bottom of `.gitconfig` — currently `~/repos/work/` → work; `~/repos/personal/`, `~/repos/tools/`, and `~/Documents/` → personal. Adjust those paths if a machine's layout differs.

Two related bits of per-machine setup:

- Commit/tag signing is on (`gpg.format = ssh`), so `signingKey` must point at a real key — the SSH key from the Manual Setup section works.
- Verifying signatures (`git log --show-signature`) additionally needs `~/.ssh/allowed_signers`, e.g.: `echo "your@email.com $(cat ~/.ssh/id_ed25519.pub)" > ~/.ssh/allowed_signers`

`link_dotfiles.sh` warns if the identity files are missing.
