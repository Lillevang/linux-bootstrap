---
name: new-step
description: Scaffold a new numbered bootstrap step script in fedora/scripts/ following this repo's conventions. Use when adding a new install/setup step (e.g. "add a step for fonts", "/new-step 70 flatpaks").
---

Create a new step script in `fedora/scripts/`. Arguments (optional): a number and/or a short name, e.g. `70 flatpaks`. `$ARGUMENTS`

1. List `fedora/scripts/` to see existing numbers. If no number was given, pick the next free multiple of 10. If the step must run before/after an existing one, slot it accordingly (order is execution order — e.g. anything needing RPM Fusion goes after 20).
2. Name it `NN_short_name.sh` (lowercase, underscores).
3. Start from this template and match `10_dnf_tuning.sh` for style:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

   - 2-space indent, uppercase constants at the top, quoted expansions, `local` in functions.
   - `sudo dnf -y install` for packages, long lists one-per-line with trailing `\`.
   - Any `dnf copr enable` needs `-y` (it's interactive otherwise).
   - Make it best-effort idempotent where cheap (guard with a check before mutating, like `ensure_kv` in `10_dnf_tuning.sh`).
   - No echo/progress output — the new scripts are silent by convention.
4. Do not `chmod +x` — scripts in this repo are run via `bash script.sh`.
5. Run `shellcheck` on the new file and fix any findings.
6. If content for the step exists in git history (deleted legacy `scripts/`), check `git show HEAD:scripts/<old_name>.sh` for reference, but rewrite to current conventions rather than copying.
