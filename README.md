# Linux Bootstrap

Bootstrap toolkit for setting up fresh Linux machines. Distro-scoped: each supported distro gets its own directory containing numbered base steps, per-machine optional units, and dotfiles.

## Distros

- **[fedora/](fedora/README.md)** — Fedora (dnf): base steps (shell, editor, CLI tools, dotfile symlinks), optional units (`kube`, `go`, `rust`, `zig`, `crystal`, …) selected per machine via `machines/<hostname>.conf`, and git identity setup.

## Testing

```bash
bash test/fedora_vm_test.sh              # full bootstrap against a clean Fedora Cloud VM
OPTIONAL=all bash test/fedora_vm_test.sh # also run and verify every optional unit
```

The test boots a pristine VM with qemu+KVM, copies in the local working tree (uncommitted changes included), runs everything, and verifies the result — see the fedora README for details.
