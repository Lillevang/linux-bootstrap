#!/usr/bin/env bash
set -euo pipefail

FAILED_STEPS=()
SUCCEEDED_STEPS=()

run_step() {
  local description="$1"
  local script="$2"

  echo "🔧 $description..."
  if bash "$script"; then
    SUCCEEDED_STEPS+=("$description")
  else
    echo "❌ Failed: $description"
    FAILED_STEPS+=("$description")
  fi
}

echo "🚀 Starting system bootstrap..."

run_step "Creating base folders" "./scripts/create_folders.sh"
run_step "Installing base tools" "./scripts/install_tools.sh"
run_step "Installing languages" "./scripts/install_languages.sh"
run_step "Installing Helix and LSPs" "./scripts/install_editors.sh"
run_step "Installing Kubernetes tools" "./scripts/install_kube_tools.sh"
run_step "Installing Zsh + Oh My Zsh" "./scripts/install_oh_my_zsh.sh"
run_step "Linking dotfiles" "./link_dotfiles.sh"
run_step "Running Go updater" "./scripts/go-updater/go-updater.sh"

echo
echo "✅ Bootstrap Summary:"
echo "------------------------"
for s in "${SUCCEEDED_STEPS[@]}"; do
  echo "✔️  $s"
done
if [ ${#FAILED_STEPS[@]} -ne 0 ]; then
  echo
  echo "❌ Failed Steps:"
  for f in "${FAILED_STEPS[@]}"; do
    echo "   - $f"
  done
  echo
  echo "⚠️  Please review the failed steps above and re-run manually if needed."
else
  echo
  echo "🎉 All steps completed successfully!"
fi
