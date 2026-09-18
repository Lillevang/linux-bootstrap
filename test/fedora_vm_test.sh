#!/usr/bin/env bash
set -euo pipefail

# End-to-end test: boot a clean Fedora Cloud VM (qemu+kvm, no libvirt
# needed), copy the local working tree in, run every numbered step plus
# link_dotfiles.sh, then verify the result. Usage:
#
#   bash test/fedora_vm_test.sh          # full run, VM is destroyed after
#   KEEP=1 bash test/fedora_vm_test.sh   # leave the VM running for inspection
#   bash test/fedora_vm_test.sh ssh      # ssh into a VM kept with KEEP=1
#
# The ~700MB cloud image is downloaded once and cached; each run boots a
# fresh throwaway overlay, so the VM is always clean.

FEDORA_VER="43"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_DIR="$HOME/.cache/linux-bootstrap-vmtest"
BASE_IMG="$CACHE_DIR/fedora-${FEDORA_VER}-cloud.qcow2"
WORK_IMG="$CACHE_DIR/work.qcow2"
SEED_ISO="$CACHE_DIR/seed.iso"
SSH_KEY="$CACHE_DIR/id_test"
PID_FILE="$CACHE_DIR/qemu.pid"
CONSOLE_LOG="$CACHE_DIR/console.log"
SSH_PORT="${SSH_PORT:-2222}"
VM_USER="test"

SSH_OPTS=(
  -i "$SSH_KEY"
  -p "$SSH_PORT"
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o LogLevel=ERROR
)

vm_ssh() {
  # shellcheck disable=SC2029  # client-side expansion of $@ is intended
  ssh "${SSH_OPTS[@]}" "$VM_USER@127.0.0.1" "$@"
}

vm_destroy() {
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    kill "$(cat "$PID_FILE")"
  fi
  rm -f "$PID_FILE"
}

if [ "${1:-}" = "ssh" ]; then
  exec ssh "${SSH_OPTS[@]}" "$VM_USER@127.0.0.1"
fi

mkdir -p "$CACHE_DIR"

# --- fetch base image (cached across runs) ---
if [ ! -f "$BASE_IMG" ]; then
  BASE_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${FEDORA_VER}/Cloud/x86_64/images"
  IMG_NAME="$(curl -fsSL "$BASE_URL/" | grep -oE 'Fedora-Cloud-Base-Generic[^"<]*\.qcow2' | head -1)"
  [ -n "$IMG_NAME" ] || {
    echo "could not resolve cloud image name from $BASE_URL" >&2
    exit 1
  }
  echo "downloading $IMG_NAME ..."
  curl -fL --progress-bar -o "$BASE_IMG.part" "$BASE_URL/$IMG_NAME"
  mv "$BASE_IMG.part" "$BASE_IMG"
fi

# --- ephemeral ssh key + cloud-init seed ---
[ -f "$SSH_KEY" ] || ssh-keygen -q -t ed25519 -N '' -f "$SSH_KEY"

cat >"$CACHE_DIR/user-data" <<EOF
#cloud-config
users:
  - name: $VM_USER
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - $(cat "$SSH_KEY.pub")
EOF
cat >"$CACHE_DIR/meta-data" <<EOF
instance-id: linux-bootstrap-test
local-hostname: bootstrap-test
EOF
genisoimage -quiet -output "$SEED_ISO" -volid cidata -joliet -rock \
  "$CACHE_DIR/user-data" "$CACHE_DIR/meta-data"

# --- boot a fresh overlay ---
vm_destroy
rm -f "$WORK_IMG"
qemu-img create -q -f qcow2 -b "$BASE_IMG" -F qcow2 "$WORK_IMG" 25G

qemu-system-x86_64 \
  -machine q35,accel=kvm \
  -cpu host -m 4096 -smp 4 \
  -drive "file=$WORK_IMG,if=virtio" \
  -cdrom "$SEED_ISO" \
  -nic "user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:${SSH_PORT}-:22" \
  -display none \
  -serial "file:$CONSOLE_LOG" \
  -pidfile "$PID_FILE" \
  -daemonize

echo "waiting for ssh (console: $CONSOLE_LOG) ..."
for _ in $(seq 60); do
  if vm_ssh -o ConnectTimeout=3 true 2>/dev/null; then
    break
  fi
  sleep 5
done
vm_ssh true || {
  echo "VM never became reachable" >&2
  vm_destroy
  exit 1
}

# --- copy the local working tree (not a clone: tests uncommitted work) ---
echo "copying working tree ..."
tar -C "$REPO_DIR" --exclude=.git -czf - . | vm_ssh 'mkdir -p linux-bootstrap && tar -xzf - -C linux-bootstrap'

# --- run every step in order, then link dotfiles ---
run_remote() {
  echo
  echo "===== $1"
  vm_ssh "cd linux-bootstrap/fedora && $2"
}

FAILED=0
for script in "$REPO_DIR"/fedora/scripts/*.sh; do
  name="$(basename "$script")"
  run_remote "$name" "bash scripts/$name" || {
    echo "!!!!! $name FAILED"
    FAILED=1
    break
  }
done
if [ "$FAILED" -eq 0 ]; then
  run_remote "link_dotfiles.sh" "bash link_dotfiles.sh" || {
    echo "!!!!! link_dotfiles.sh FAILED"
    FAILED=1
  }
fi

# --- OPTIONAL=all: run every optional unit, then the manifest runner ---
if [ "$FAILED" -eq 0 ] && [ "${OPTIONAL:-}" = "all" ]; then
  UNITS="$(for f in "$REPO_DIR"/fedora/optional/*.sh; do basename "$f" .sh; done | grep -vx run)"
  for unit in $UNITS; do
    run_remote "optional/$unit" "bash optional/$unit.sh" || {
      echo "!!!!! optional/$unit FAILED"
      FAILED=1
      break
    }
  done
  if [ "$FAILED" -eq 0 ]; then
    UNITS_ONELINE="$(echo "$UNITS" | tr '\n' ' ')"
    run_remote "optional/run.sh (idempotent re-run)" \
      "printf '%s\n' $UNITS_ONELINE > /tmp/all.conf && bash optional/run.sh /tmp/all.conf" || {
      echo "!!!!! optional/run.sh FAILED"
      FAILED=1
    }
  fi
fi

# --- verify ---
if [ "$FAILED" -eq 0 ]; then
  echo
  echo "===== verification"
  vm_ssh "OPTIONAL='${OPTIONAL:-}' bash -s" <<'EOF' || FAILED=1
set -u
export PATH="$HOME/.local/bin:$PATH"
fail=0
check() {
  if eval "$2" >/dev/null 2>"$HOME/.check_err"; then
    echo "ok:   $1"
  else
    echo "FAIL: $1"
    sed 's/^/        /' "$HOME/.check_err"
    fail=1
  fi
}
health_green() {
  local out
  out="$(hx --health "$1" 2>/dev/null)"
  if printf '%s\n' "$out" | grep '✘' >&2; then
    return 1
  fi
}
check "login shell is zsh"          '[ "$(getent passwd "$USER" | cut -d: -f7)" = "$(command -v zsh)" ]'
check "zsh starts and loads config" 'zsh -ic true'
check ".zshrc symlinked"            '[ -L "$HOME/.zshrc" ]'
check ".gitconfig symlinked"        '[ -L "$HOME/.gitconfig" ]'
check ".p10k.zsh symlinked"         '[ -L "$HOME/.p10k.zsh" ]'
check "oh-my-zsh present"           '[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]'
check "powerlevel10k present"       '[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]'
check "zoxide installed"            'command -v zoxide'
check "helix installed"             'command -v hx'
check "yazi installed"              'command -v yazi'
check "fzf installed"               'command -v fzf'
check "sublime merge installed"     'command -v smerge'
check "~/repos created"             '[ -d "$HOME/repos" ]'
check "~/.local/bin created"        '[ -d "$HOME/.local/bin" ]'
check "rpmfusion enabled"           'dnf repolist --enabled | grep -q rpmfusion-free'
check "node + npm installed"        'command -v node && command -v npm'
check "uv + ruff installed"         'command -v uv && command -v ruff'
check "pylsp installed"             'command -v pylsp'
check "just installed"              'command -v just'
check "task installed"              'command -v task'
check "make installed"              'command -v make'
check "jq installed"                'command -v jq'
check "search tools installed"      'command -v rg && command -v fd && command -v bat && command -v tree'
check "git tooling installed"       'command -v gh && command -v delta'
check "qol tools installed"         'command -v eza && command -v btop && command -v direnv && command -v duf && command -v dust && command -v procs && command -v chezmoi && command -v hyperfine && command -v fastfetch && command -v atuin && command -v yq'
check "podman stack installed"       'command -v podman && command -v podman-compose && command -v buildah && command -v skopeo'
check "docker ce not installed"      '! rpm -q docker-ce >/dev/null 2>&1'
check "helix config symlinked"      '[ -L "$HOME/.config/helix/config.toml" ] && [ -L "$HOME/.config/helix/languages.toml" ]'
check "hx health python all green"  'health_green python'
check "hx health bash all green"    'health_green bash'

if [ "${OPTIONAL:-}" = "all" ]; then
  check "kubectl installed"          'command -v kubectl'
  check "helm installed"             'command -v helm'
  check "k9s installed"              'command -v k9s'
  check "hx health go all green"     'health_green go'
  check "hx health rust all green"   'health_green rust'
  check "hx health zig all green"    'health_green zig'
  check "hx health crystal all green" 'health_green crystal'
fi
exit "$fail"
EOF
fi

echo
if [ "${KEEP:-0}" = "1" ]; then
  echo "VM left running — 'bash test/fedora_vm_test.sh ssh' to inspect, kill $(cat "$PID_FILE") to stop"
else
  vm_destroy
  echo "VM destroyed"
fi

if [ "$FAILED" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
  exit 1
fi
