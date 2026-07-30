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
bash scripts/25_terra.sh       # enable Terra repo (crystal lives there)
bash scripts/30_packages.sh    # desktop/CLI package set (incl. yazi copr)
bash scripts/40_multimedia.sh  # multimedia group (needs RPM Fusion first)
bash scripts/50_ohmyzsh.sh     # Oh My Zsh + powerlevel10k + plugins, chsh to zsh
bash scripts/70_sublime_merge.sh # Sublime Merge (the mergetool set in .gitconfig)
bash link_dotfiles.sh          # symlink dotfiles/ into $HOME
```

Notes:

- Steps 10–40 and 70 need sudo. `50_ohmyzsh.sh` is user-scope, but `chsh` asks for your password when zsh isn't the login shell yet.
- Order matters: `20_rpmfusion.sh` must run before `40_multimedia.sh`, `25_terra.sh` before `30_packages.sh` (crystal), and `30_packages.sh` (zsh, git) before `50_ohmyzsh.sh`.
- `link_dotfiles.sh` must be run from inside `fedora/` — it resolves `dotfiles/` relative to the current directory. Existing files are backed up to `~/.dotfiles_backup` before linking; already-correct symlinks are skipped.
- `60_helix.sh` (language servers, yazi config) is a stub — not implemented yet.
- The kubectl aliases in `.zshrc` and the nvm block only activate when those tools are installed, so the shared dotfiles work on machines with or without them. (Optional per-machine installs for node/kube/language tooling are planned.)

---

## 🧪 Testing

`test/fedora_vm_test.sh` (repo root) boots a **clean Fedora Cloud VM** with plain qemu+KVM (no libvirt setup needed), copies the local working tree in — uncommitted changes included — runs every numbered step plus `link_dotfiles.sh`, and then runs a battery of verification checks (login shell, symlinks, installed tools, enabled repos).

```bash
bash test/fedora_vm_test.sh          # full run; prints RESULT: PASS/FAIL, destroys VM
KEEP=1 bash test/fedora_vm_test.sh   # same, but leaves the VM running
bash test/fedora_vm_test.sh ssh      # shell into a kept VM
```

The ~700MB cloud image is cached in `~/.cache/linux-bootstrap-vmtest/` after the first run; every run boots a fresh disk overlay, so the VM is always pristine. Boot messages land in `console.log` next to the cache if a run hangs before ssh comes up.

---

## 🗂️ Dotfiles

Personal dotfiles live under `dotfiles/` and get symlinked into `$HOME` by `link_dotfiles.sh`. The Helix configs (`config.toml`, `languages.toml`) belong in `~/.config/helix/` and are not linked automatically yet.

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
