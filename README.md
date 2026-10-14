# c0depool-pc-setup

Ansible-based post-install setup for a Fedora KDE workstation. It installs and
configures the basics — RPM Fusion, multimedia codecs, gaming tools, Flatpak
apps, and a set of CLI/admin utilities — and keeps everything idempotent so it
can be re-run safely.

Runs **locally only** (no SSH): the play targets `localhost` via a local
connection.

## Layout

```
bootstrap.sh          # installs Ansible + prerequisites, then runs the playbook
ansible.cfg           # local config (inventory, become, roles path)
inventory.ini         # localhost with connection: local
pc-setup.yaml         # main playbook (wires the roles together)
group_vars/all.yaml   # ALL variables (packages, flatpaks, toggles)
requirements.yaml     # ansible-galaxy collections
roles/
  system_upgrade/     # full dnf upgrade + autoremove
  dnf_packages/       # repos (RPM Fusion, VS Code) + dnf package install/remove
  flatpak_apps/       # Flathub remote + flatpak app install
```

## Usage

First run (installs Ansible, then applies everything):

```bash
bash bootstrap.sh
```

Subsequent runs (Ansible already installed):

```bash
ansible-playbook pc-setup.yaml --ask-become-pass
```

Run only part of it with tags:

```bash
ansible-playbook pc-setup.yaml --ask-become-pass --tags dnf
ansible-playbook pc-setup.yaml --ask-become-pass --tags flatpak
ansible-playbook pc-setup.yaml --ask-become-pass --tags upgrade
```

Dry run (no changes):

```bash
ansible-playbook pc-setup.yaml --ask-become-pass --check --diff
```

## Upgrading on demand

The default state is `present` (install only). To also upgrade, override the
state variable on the command line with `-e`:

```bash
# Upgrade the listed dnf packages
ansible-playbook pc-setup.yaml --ask-become-pass --tags dnf -e dnf_packages_state=latest

# Update the listed Flatpak apps
ansible-playbook pc-setup.yaml --ask-become-pass --tags flatpak -e flatpak_apps_state=latest

# Upgrade everything (full dnf upgrade + dnf packages + flatpaks)
ansible-playbook pc-setup.yaml --ask-become-pass -e dnf_packages_state=latest -e flatpak_apps_state=latest
```

## Customizing

Edit `group_vars/all.yaml`:

- `dnf_packages` — grouped package lists (basic, hardware, codecs, gaming, editors)
- `dnf_packages_remove` — packages to remove
- `dnf_packages_state` — `present` (install only) or `latest` (also upgrade)
- `copr_repos` — extra COPR repos to enable (e.g. `lizardbyte/stable` for Sunshine)
- `flatpak_apps` — Flatpak application IDs
- `flatpak_apps_state` — `present` (install only) or `latest` (also update)
- `system_upgrade_enabled`, `rpmfusion_enabled`, `vscode_repo_enabled` — feature toggles

Everything is idempotent: re-running makes no changes once the system matches
the desired state.

## Disclaimer

This repository was written with the assistance of AI coding tools. The
playbook and scripts are provided as-is, without warranty of any kind. Review
the code before running it — especially the `system_upgrade` role, which
performs a full `dnf upgrade` — and test in a safe environment first. You are
responsible for any changes made to your system.
