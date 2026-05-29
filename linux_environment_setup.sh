#!/bin/bash
# This script can be run on a new Linux installation to set up directories and dotfiles
# Run with the command 
# wget -O - https://raw.githubusercontent.com/JoshDesmond/dotfiles/master/linux_environment_setup.sh | sudo bash
# The script as is configured for running once dotfiles has already been cloned, however

if [[ $EUID > 0 ]] ; then
	echo "Error: Script must be run as root"
	exit 2
fi

# TODO verify the script isn't malicious somehow (do a SHA1 check on the file or something?)

sudo apt-get --assume-yes update
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes autoclean
sudo apt-get --assume-yes install git openssh-client keychain

# Setup ~/code/ folders
code_dir="/home/$SUDO_USER/code"
mkdir -p "$code_dir"/{online,personal,others}
chown -R "$SUDO_USER:$SUDO_USER" "$code_dir"

# Clone the dotfiles repo on first run, then hand off to the cross-platform
# master composer (bashrc, git, ssh, neovim, node, etc.).
DOTFILES_DIR="$code_dir/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
	sudo -u "$SUDO_USER" git clone https://github.com/JoshDesmond/dotfiles.git "$DOTFILES_DIR"
fi
if [ -x "$DOTFILES_DIR/setup.sh" ]; then
	sudo -u "$SUDO_USER" "$DOTFILES_DIR/setup.sh"
else
	echo "Note: $DOTFILES_DIR/setup.sh not found; run it manually after cloning."
fi

exit 0
