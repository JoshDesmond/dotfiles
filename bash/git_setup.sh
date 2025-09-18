#!/bin/bash

# Do some git setup
git config --global user.email "JoshDesmond@users.noreply.github.com"
git config --global user.name "JoshDesmond"
git remote set-url origin "git@github.com:JoshDesmond/dotfiles.git"

# Additional git configuration
git config --global core.editor nvim
git config --global push.autoSetupRemote true
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_rsa.pub # TODO, update this to match ssh_setup.sh
git config --global commit.gpgsign true
git config --global init.defaultBranch main
git config --global pull.rebase true
