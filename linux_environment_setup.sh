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

# Update 
sudo apt-get --assume-yes update 
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes autoclean

# Install packages
sudo apt-get --assume-yes install git
sudo apt-get --assume-yes install openssh-client
sudo apt-get --assume-yes install keychain

# Setup ~/code/ folders
cd /home/$SUDO_USER/
code_dir="/home/$SUDO_USER/code"
if [[ ! -d $code_dir ]]; then
	mkdir code
	chown $SUDO_USER:$SUDO_USER code
fi
cd $code_dir
mkdir online
mkdir personal
mkdir others
chown -R $SUDO_USER:$SUDO_USER school/ online/ personal/ others/

# TODO: if no dotfiles, then clone the repository here
# git clone https://github.com/JoshDesmond/dotfiles.git

# Orchestrate other scripts like
# - bash/bashrc_setup.sh
# - bash/git_setup.sh
# - bash/install_scripts.sh
# - neovim/neovim_rc_setup.sh
# - ssh/ssh_setup.sh

exit 0
