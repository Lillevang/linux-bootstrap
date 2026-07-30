# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal machine-bootstrap repo, mid-restructure on `feature/start-over`. The old flat layout (root `install.sh` + `scripts/`) is deleted; the new layout is distro-scoped, starting with `fedora/`. More distro dirs may be added later — don't flatten `fedora/` back to the root.

## Running and linting

- `fedora/scripts/` contains numbered *base* step scripts (`NN_name.sh`) meant to run in numeric order on every machine. There is no orchestrator for them yet — run steps individually: `bash fedora/scripts/10_dnf_tuning.sh`.
- `fedora/optional/` contains self-contained, idempotent per-machine units (kube, go, rust, zig, crystal, …). `optional/run.sh` applies the units listed in `fedora/machines/<hostname>.conf` (committed, one unit per line). Units assume the base steps already ran (node/npm, uv, jq, helix are base).
- Definition of done for a language unit: `hx --health <lang>` all green. `dotfiles/languages.toml` carries overrides that keep that contract honest — check it before assuming helix defaults.
- Scripts are not executable (mode 644); invoke with `bash`, not `./`.
- Lint with `shellcheck fedora/scripts/*.sh fedora/optional/*.sh fedora/link_dotfiles.sh test/*.sh` before committing. There is no CI.
- End-to-end test: `bash test/fedora_vm_test.sh` boots a clean Fedora Cloud VM (qemu+KVM) and runs everything; `OPTIONAL=all` includes the optional units. Prefer running it after nontrivial script changes — it has caught host-vs-clean-machine drift repeatedly.

## Script conventions

- `#!/usr/bin/env bash` + `set -euo pipefail` on every script (the copied `link_dotfiles.sh` predates this and lacks both).
- 2-space indent, uppercase constants at top of file, all expansions quoted, `local` in functions.
- `sudo dnf -y install ...` with long package lists one-per-line with trailing `\`.
- Idempotency is best-effort, not a hard contract — follow the `ensure_kv` pattern in `10_dnf_tuning.sh` where it's cheap, but don't contort scripts for it.

## Gotchas

- Step order matters: `20_rpmfusion.sh` before `40_multimedia.sh` (multimedia group needs RPM Fusion); `30_packages.sh` before 50/55/60 (git, uv, helix).
- Steps 10–40 and 70 need sudo; `00_dirs.sh`, 50/55/60, and `link_dotfiles.sh` are user-scope (50 sudo's only for `chsh`).
- `fedora/link_dotfiles.sh` uses `$(pwd)` — it only works when run from inside `fedora/`. It only globs `$HOME` dotfiles (`.*`); the Helix configs (`config.toml`/`languages.toml` → `~/.config/helix/`) are linked by `60_helix.sh` instead.
- `~/.gitconfig-personal` / `~/.gitconfig-work` are deliberately NOT tracked (identity split via `includeIf`; see README "Git Identity"). Don't add them to `dotfiles/`.
- Third-party repos are set up where they're needed: yazi copr + Task cloudsmith in `30_packages.sh`, Terra in `optional/crystal.sh`, upstream Kubernetes in `optional/kube.sh`, sublimehq in `70_sublime_merge.sh`. dnf5 does NOT expand `$releasever` in `--setopt=repo.gpgkey`; expand via `rpm -E %fedora` (see `optional/crystal.sh`).
- The `.zshrc` guards (nvm block, `command -v kubectl` around the k8s aliases) are load-bearing for the base/optional split — keep new optional-tool references guarded the same way.
- Binaries not packaged anywhere land in `~/.local/bin` (zls, crystalline, ameba, golangci-lint-langserver) — the VM test's verification exports that onto PATH explicitly because non-login shells don't.