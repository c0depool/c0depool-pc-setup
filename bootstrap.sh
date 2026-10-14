#!/usr/bin/env bash
# Bootstrap: install Ansible + minimal prerequisites, then run the playbook.
# Run as a normal user (it calls sudo itself):  bash bootstrap.sh
# Safe to re-run. Idempotent: only installs what is missing.

set -uo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Run this as your normal user, not root (it uses sudo where needed)." >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!! %s\033[0m\n' "$*"; }

# ------------------------------------------------------------- 1. prerequisites
log "Installing bootstrap prerequisites (dnf, python3, git)"
# ansible-core needs python3; git is handy for pulling collections later.
sudo dnf install -y dnf python3 git

# ------------------------------------------------------------------- 2. ansible
log "Installing Ansible"
if command -v ansible-playbook >/dev/null 2>&1; then
  echo "Ansible already installed: $(ansible --version | head -1)"
else
  # Fedora ships the full 'ansible' bundle (includes ansible-core + collections).
  sudo dnf install -y ansible
fi

# ------------------------------------------------------------------- 3. next steps
log "Bootstrap complete"
echo
echo "Ansible is installed. Run the playbook manually from $SCRIPT_DIR:"
echo
echo "  cd \"$SCRIPT_DIR\""
echo "  ansible-playbook pc-setup.yaml --ask-become-pass"
echo
echo "Useful variants:"
echo "  ansible-playbook pc-setup.yaml --ask-become-pass --check --diff   # dry run"
echo "  ansible-playbook pc-setup.yaml --ask-become-pass --tags dnf       # only dnf"
echo "  ansible-playbook pc-setup.yaml --ask-become-pass --tags flatpak   # only flatpak"
echo "  ansible-playbook pc-setup.yaml --ask-become-pass --tags upgrade   # only upgrade"
