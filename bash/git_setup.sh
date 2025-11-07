#!/bin/bash

# Do some git setup
git config --global user.email "JoshDesmond@users.noreply.github.com"
git config --global user.name "JoshDesmond"
git remote set-url origin "git@github.com:JoshDesmond/dotfiles.git"

# Additional git configuration
git config --global core.editor nvim
git config --global push.autoSetupRemote true
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global init.defaultBranch main
git config --global pull.rebase true

# SSH Key setup
KEY_PUB="$HOME/.ssh/id_ed25519.pub" # TODO, update this to match ssh_setup.sh
if [[ -f "$KEY_PUB" ]]; then
    git config --global user.signingkey "$KEY_PUB"
else
    echo "Warning: SSH public key not found at $KEY_PUB, skipping signing key setup"
fi
