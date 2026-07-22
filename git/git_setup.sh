#!/usr/bin/env bash
# git_setup.sh — Point the system git config at the dotfiles git config.
#
# Sets ~/.gitconfig to include git/.gitconfig from this repo.
# Optionally sets the dotfiles repo origin remote to SSH.
#
# Usage:
#   ./git/git_setup.sh [--help]

set -e

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

# Resolve paths for the system git config, dotfiles git config, and dotfiles root
GIT_DIR="$(cd "${0%/*}" && pwd)"
DOTFILES_ROOT="$(cd "$GIT_DIR/.." && pwd)"
SYSTEM_GITCONFIG="$HOME/.gitconfig"
DOTFILES_GITCONFIG="$GIT_DIR/.gitconfig"
DOTFILES_GITCONFIG_PATH="$DOTFILES_GITCONFIG"
SYSTEM_GITCONFIG_HEADER="# Managed by dotfiles git/git_setup.sh."

# Verify the dotfiles git config exists before pointing the system config at it
if [[ ! -f "$DOTFILES_GITCONFIG" ]]; then
	echo "Error: dotfiles git config not found at $DOTFILES_GITCONFIG" >&2
	exit 1
fi

# Skip setup if the system git config already points at the dotfiles git config
if [[ -f "$SYSTEM_GITCONFIG" ]] && grep -Fq "$DOTFILES_GITCONFIG_PATH" "$SYSTEM_GITCONFIG"; then
	echo "$SYSTEM_GITCONFIG already points at the dotfiles git config:"
	echo "======== $SYSTEM_GITCONFIG ========"
	cat "$SYSTEM_GITCONFIG"
	echo "==================================="
else
	# Back up the existing system git config before replacing it
	if [[ -f "$SYSTEM_GITCONFIG" ]]; then
		BACKUP="$SYSTEM_GITCONFIG.bak.$(date +%Y%m%d%H%M%S)"
		echo "Backing up existing $SYSTEM_GITCONFIG to $BACKUP"
		cp "$SYSTEM_GITCONFIG" "$BACKUP"
	fi

	# Point the system git config at the dotfiles git config
	cat > "$SYSTEM_GITCONFIG" <<EOF
$SYSTEM_GITCONFIG_HEADER
[include]
	path = $DOTFILES_GITCONFIG_PATH
EOF
	echo "Wrote $SYSTEM_GITCONFIG"
fi

# Warn when the signing key file is missing (matches ssh/ssh_setup.sh defaults)
KEY_PUB="$HOME/.ssh/id_rsa.pub"
if [[ ! -f "$KEY_PUB" ]]; then
	echo "Warning: SSH public key not found at $KEY_PUB, skipping signing key setup"
fi

# Point the dotfiles repo origin at GitHub over SSH when run from the repo
if git -C "$DOTFILES_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
	git -C "$DOTFILES_ROOT" remote set-url origin "git@github.com:JoshDesmond/dotfiles.git"
	echo "Set dotfiles origin remote to git@github.com:JoshDesmond/dotfiles.git"
fi

echo "Git setup complete."
