#!/bin/bash
# Master setup script. Composes the per-tool setup scripts to bootstrap
# a fresh machine (bash, git, ssh, neovim, node, packages).
#
# Run from the dotfiles repo root:
#   ./setup.sh
#
# This script is intentionally a thin composer -- each sub-script owns
# its own logic. Strategy-pattern branching for OS-specific bits lives
# in bash/install_packages.sh.

set -e

# cd to the directory this script is in so the relative paths below work.
cd "${0%/*}"
DOTFILES_ROOT="$PWD"

# Reuse the OS detection / package install helpers.
source "$DOTFILES_ROOT/bash/install_packages.sh"

OS="$(detect_os)"
echo "Detected OS: $OS"

if [ "$OS" = "unknown" ]; then
	echo "Error: unsupported OS. Aborting."
	exit 1
fi

# 1. Base packages (git, ssh client, keychain, etc.)
echo
echo "==== Installing base packages ===="
install_packages

# 2. ~/code/ folder structure (mirrors linux_environment_setup.sh).
echo
echo "==== Setting up ~/code/ folders ===="
CODE_DIR="$HOME/code"
mkdir -p "$CODE_DIR/online" "$CODE_DIR/personal" "$CODE_DIR/others"

# 3. SSH key (only generates if missing; ssh_setup.sh handles that itself).
echo
echo "==== SSH setup ===="
"$DOTFILES_ROOT/ssh/ssh_setup.sh" || echo "ssh_setup.sh exited non-zero (likely key already exists); continuing."

# 4. Git config (needs the SSH key from step 3 for signing).
echo
echo "==== Git setup ===="
"$DOTFILES_ROOT/bash/git_setup.sh"

# 5. Bashrc / bash_profile sourcing of personal config + aliases.
echo
echo "==== Bashrc setup ===="
"$DOTFILES_ROOT/bash/bashrc_setup.sh"

# 6. Neovim / vim / ideavim init files.
echo
echo "==== Neovim setup ===="
"$DOTFILES_ROOT/neovim/neovim_rc_setup.sh"

# 7. Node / npm defaults. Only run if npm is on PATH; node isn't installed
# by the base package list above.
echo
echo "==== Node setup ===="
if command -v npm >/dev/null 2>&1; then
	"$DOTFILES_ROOT/node/node_setup.sh"
else
	echo "npm not found on PATH; skipping node_setup.sh. Install Node.js and re-run it manually."
fi

echo
echo "==== Done ===="
echo "Open a new shell (or 'source ~/.bashrc') to pick up the new config."
echo
echo "==== Optional: SeaCrit (encrypted .env vault) ===="
echo "    git clone git@github.com:JoshDesmond/seacrit.git ~/code/seacrit"
