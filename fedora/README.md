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

## 🧰 Tool inventory

The bootstrap installs a fairly broad workstation/tooling baseline. This is the practical cheat sheet for what is there, how to invoke it, and when it is useful.

| Tool | What it is | How to use | When to use it |
|---|---|---|---|
| Git | Version control | `git status`, `git diff`, `git switch`; shell aliases include `gs`, `ga`, `gc`, `gp`, `gl` | Everyday source control |
| git-delta | Better Git diff pager | Used automatically by `git diff` / `git show` | Reading diffs and conflicts |
| gh | GitHub CLI | `gh pr view`, `gh pr checkout 123`, `gh issue list` | PRs, issues and repo operations without the browser |
| Sublime Merge | GUI Git client and configured mergetool | `smerge .`, `git mergetool` | Visual history and awkward merge conflicts |
| fzf | Fuzzy finder | Pipe text into `fzf`; also powers shell helpers | Selecting from long lists when exact names are inconvenient |
| Atuin | Searchable shell history | `Ctrl-R` | Finding old commands quickly |
| zoxide | Smarter directory navigation | `cd partial-name` | Jumping to frequently used directories |
| direnv | Per-directory environment | Add `.envrc`, then `direnv allow` | Project-specific env vars and credentials |
| eza | Modern `ls` | `ls`, `ll`, `la`, `tree` are wired to eza | Everyday directory browsing |
| bat | Syntax-aware file viewer | `b file.yaml` or `bat file.yaml` | Reading config/code in the terminal |
| ripgrep | Fast recursive text search | `rg 'pattern'`, `rg foo src/` | Searching codebases |
| fd | Friendlier file finder | `fd nginx`, `fd '\.yaml

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
` | Finding files without elaborate `find` expressions |
| yazi | Terminal file manager | `yazi` | Interactive terminal file browsing |
| jq | JSON processor | `jq '.items[].metadata.name' file.json` | APIs, scripts and Kubernetes JSON |
| yq | YAML processor | `yq '.spec.template.spec' file.yaml` | Kubernetes, Helm and CI config |
| tree | Directory tree tool | `tree`; shell alias prefers eza's tree view | Inspecting repo/layout structure |
| btop | Interactive system monitor | `bt` or `btop` | CPU, RAM and process inspection |
| duf | Disk/filesystem overview | `disks` or `duf` | Free-space and mount overview |
| dust | Visual disk-usage tool | `usage` or `dust .` | Finding large directories |
| procs | Friendlier process listing | `processes` or `procs nginx` | Inspecting running processes |
| fastfetch | System summary | `fastfetch` | Quick OS/hardware overview |
| hyperfine | Command benchmarker | `hyperfine 'cmd1' 'cmd2'` | Comparing command/build/shell performance |
| chezmoi | Dotfile manager | `chezmoi diff`, `chezmoi apply` | Available for experimentation; bootstrap still uses symlinks |
| Helix | Terminal editor | `hx file`, `hx .`, `hx --health` | Main code/config editor |
| uv | Fast Python package/env/tool manager | `uv venv`, `uv run`, `uv tool install ...` | Python projects and CLI tools |
| ruff | Python linter/formatter | `ruff check .`, `ruff format .` | Python quality and formatting |
| python-lsp-server | Python LSP | Used automatically by Helix | Python completion/navigation/diagnostics |
| ShellCheck | Shell linter | `shellcheck script.sh` | Checking shell scripts |
| shfmt | Shell formatter | `shfmt -w script.sh` | Formatting shell scripts |
| make | Traditional build/task runner | `make`, `make test` | Existing projects using Makefiles |
| just | Modern command runner | `just`, `just test` | Simple project recipes when you control the project |
| Task | Taskfile runner | `task`, `task --list` | Cross-platform project automation |
| Podman | Rootless container engine | `podman run`, `podman ps`, `podman build` | Local containers |
| podman-compose | Compose-style Podman orchestration | `podman-compose up -d` | Existing compose-oriented local stacks |
| Buildah | OCI image builder | `buildah bud -t image .` | Scripted/container-native image builds |
| Skopeo | Registry/image inspection and copy tool | `skopeo inspect docker://...`, `skopeo copy ...` | Registry work without pulling images locally |
| Zsh | Interactive shell | Default login shell after bootstrap | Terminal work |
| Oh My Zsh | Zsh framework | Loaded automatically | Shell/plugin integration |
| Powerlevel10k | Zsh prompt theme | `p10k configure` | Prompt information and appearance |
| zsh-autosuggestions | Inline history suggestions | Type and accept the suggestion | Reusing common commands |
| zsh-syntax-highlighting | Live shell syntax highlighting | Automatic | Catching invalid commands before execution |
| zsh-completions | Extra shell completions | `Tab` | Better command completion |
| zsh-history-substring-search | History search from current input | Type part of a command, then navigate history | Recalling related commands |
| Ghostty | GPU-accelerated terminal | Launch `ghostty` | Primary terminal candidate |
| JetBrains Mono | Programming font | Select in terminal/editor settings | Code readability and terminal aesthetics |
| GNOME Tweaks | Extended GNOME settings | `gnome-tweaks` | Fonts, appearance and desktop behavior |
| GNOME Extensions | Extension management | Open the Extensions app | Enable/disable installed extensions |
| Extension Manager | Extension browser/manager | Open Extension Manager | Discovering/installing GNOME extensions |
| Forge | GNOME tiling extension | Configure via Extensions/Extension Manager | Automatic tiling while remaining in GNOME |
| Blur My Shell | GNOME visual effects | Configure via Extension Manager | Desktop aesthetics |
| Just Perfection | GNOME UI controls | Configure via Extension Manager | Trimming/tuning GNOME UI |
| Clipboard History | Searchable clipboard history | Usually bound to `Super+V` | Recovering previously copied commands, URLs and text |
| Sway | Wayland tiling window manager | Select Sway at login | Full keyboard-driven desktop experimentation |
| LocalSend | LAN file transfer | Open on sender and receiver | Quick device-to-device file transfer |
| Espanso | Text expansion | Define snippets, then type their triggers | Boilerplate, URLs, repeated text and command fragments |

### Optional units

These are installed only on machines whose manifest requests them.

| Tool | Unit | How to use | When to use it |
|---|---|---|---|
| kubectl | kube | `k`, `kgp`, `kn`, `kl`, `kctx`, `kns` | Kubernetes cluster operations |
| kctxf / knsf | kube + shell | `kctxf`, `knsf` | Fuzzy Kubernetes context/namespace switching |
| Helm | kube | `helm list`, `helm upgrade --install ...` | Kubernetes packages/releases |
| k9s | kube | `k9s` | Interactive cluster inspection |
| Go | go | `go test ./...`, `go build`, `go run` | Go development |
| gopls | go | Automatic in Helix | Go language-server features |
| Delve | go | `dlv test`, `dlv debug` | Go debugging |
| golangci-lint | go | `golangci-lint run` | Go linting |
| golangci-lint-langserver | go | Automatic in Helix | Go lint diagnostics in-editor |
| Rust / Cargo | rust | `cargo build`, `cargo test`, `cargo run` | Rust development |
| rust-analyzer | rust | Automatic in Helix | Rust language-server features |
| Clippy | rust | `cargo clippy` | Rust linting |
| rustfmt | rust | `cargo fmt` | Rust formatting |
| LLDB | rust / zig | Used by Helix as `lldb-dap` | Rust/Zig debugging |
| Zig | zig | `zig build`, `zig run` | Zig development |
| zls | zig | Automatic in Helix | Zig language-server features |
| Crystal | crystal | `crystal run`, `crystal build` | Crystal development |
| shards | crystal | `shards install`, `shards update` | Crystal dependency management |
| crystalline | crystal | Automatic in Helix | Crystal language-server features |
| ameba | crystal | `ameba` | Crystal linting |

A few high-value combinations are worth memorizing:

| Situation | Useful combo |
|---|---|
| Find text in code | `rg` + `fzf` |
| Find a file quickly | `fd` + `fzf` |
| Inspect a repository | eza/tree + bat + Git + delta |
| Investigate disk use | `disks` → `usage` |
| Investigate system load | `bt` → `processes` |
| Work with JSON/YAML | command/API output → `jq` / `yq` |
| Move around Kubernetes | `kctxf` → `knsf` → `k9s` |
| Inspect a registry image | `skopeo inspect` before pulling it |
| Build containers | `podman build` or `buildah bud` |
| Benchmark commands | `hyperfine` |
| Recover an old command | Atuin via `Ctrl-R` |
| Jump to a known directory | zoxide-enhanced `cd` |
| Load project-local environment | `.envrc` + `direnv allow` |
| Review changes | `git diff` with delta |
| Resolve ugly conflicts | `git mergetool` → Sublime Merge |

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
