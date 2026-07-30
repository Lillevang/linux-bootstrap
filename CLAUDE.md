# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal machine-bootstrap repo, mid-restructure on `feature/start-over`. The old flat layout (root `install.sh` + `scripts/`) is deleted; the new layout is distro-scoped, starting with `fedora/`. More distro dirs may be added later — don't flatten `fedora/` back to the root.

## Running and linting

- `fedora/scripts/` contains numbered step scripts (`NN_name.sh`) meant to run in numeric order. There is no orchestrator yet — one is planned to replace the old `install.sh`. Until then, run steps individually: `bash fedora/scripts/10_dnf_tuning.sh`.
- Scripts are not executable (mode 644); invoke with `bash`, not `./`.
- Lint with `shellcheck fedora/scripts/*.sh fedora/link_dotfiles.sh` before committing. There is no CI.

## Script conventions

- `#!/usr/bin/env bash` + `set -euo pipefail` on every script (the copied `link_dotfiles.sh` predates this and lacks both).
- 2-space indent, uppercase constants at top of file, all expansions quoted, `local` in functions.
- `sudo dnf -y install ...` with long package lists one-per-line with trailing `\`.
- Idempotency is best-effort, not a hard contract — follow the `ensure_kv` pattern in `10_dnf_tuning.sh` where it's cheap, but don't contort scripts for it.

## Gotchas

- Step order matters: `20_rpmfusion.sh` must run before `40_multimedia.sh` (the multimedia group needs RPM Fusion).
- Most steps (10–40) need sudo; `00_dirs.sh` and `link_dotfiles.sh` are user-scope only.
- `fedora/link_dotfiles.sh` uses `$(pwd)` — it only works when run from inside `fedora/`. It also only globs dotfiles (`.*`), so `config.toml`/`languages.toml` (Helix config, destined for `~/.config/helix/`) are never linked; that mechanism doesn't exist yet.
- `60_helix.sh` is an intentional stub (shebang + TODOs) awaiting content.
- The language installers (nvm/Node, Rust, Go), kube tools, and go-updater from the old layout were dropped — the plan is to bring them back as *optional* per-machine scripts (likely `fedora/optional/`), separate from the numbered base steps. `.zshrc` guards for them (nvm block, `command -v kubectl` around the k8s aliases) are load-bearing for that split; keep new tool references guarded the same way.