#!/bin/bash
# Sets up .bashrc

# cd to the directory this script is in
cd "${0%/*}"

# Check if .bashrc is already set up
SCRIPT_GREP_RESULT=$(grep ".bash_personal_aliases" ~/.bashrc )

if [ -n "$SCRIPT_GREP_RESULT" ] ; then
	echo ".bashrc already seems to be configured. Outputing .bashrc tail:"
	echo "======== ~/.bashrc ========"
	tail ~/.bashrc
	echo "==========================="
	printf "\nExiting script\n"
	exit 0
fi

printf "\n\n" >> ~/.bashrc
printf "source $PWD/.bash_personal_aliases\n" >> ~/.bashrc
printf "source $PWD/.bash_personal_config\n\n" >> ~/.bashrc
export PATH="$PATH:$HOME/code/dotfiles/bash/scripts"

# Set up case-insensitivity (from: https://askubuntu.com/q/87061/1039153):
# If ~/.inputrc doesn't exist yet: First include the original /etc/inputrc
# so it won't get overriden
if [ ! -a ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi
# Add shell-option to ~/.inputrc to enable case-insensitive tab completion

# Set up auto-complete cycle (from: https://unix.stackexchange.com/a/447638/403042)
echo 'set completion-ignore-case On' >> ~/.inputrc
echo 'set show-all-if-ambiguous on' >> ~/.inputrc
echo 'set show-all-if-unmodified on' >> ~/.inputrc
echo 'set menu-complete-display-prefix on' >> ~/.inputrc
echo '"\t": menu-complete' >> ~/.inputrc

source ~/.bashrc

