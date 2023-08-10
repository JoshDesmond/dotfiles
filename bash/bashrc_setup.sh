#!/bin/bash
# Sets up .bashrc or .bash_profile on macOS

# cd to the directory this script is in
cd "${0%/*}"

# Check the OS
OS="$(uname)"

# Check if .bashrc or .bash_profile (for macOS) is already set up
if [ "$OS" == "Darwin" ]; then
  BASHRC_PATH="$HOME/.bash_profile"
else
  BASHRC_PATH="$HOME/.bashrc"
fi

SCRIPT_GREP_RESULT=$(grep ".bash_personal_aliases" "$BASHRC_PATH")

if [ -n "$SCRIPT_GREP_RESULT" ]; then
	echo "$BASHRC_PATH already seems to be configured. Outputting tail:"
	echo "======== $BASHRC_PATH ========"
	tail "$BASHRC_PATH"
	echo "==========================="
	printf "\nExiting script\n"
	exit 0
fi

printf "\n\n" >> "$BASHRC_PATH"
printf "source $PWD/.bash_personal_aliases\n" >> "$BASHRC_PATH"
printf "source $PWD/.bash_personal_config\n\n" >> "$BASHRC_PATH"
export PATH="$PATH:$HOME/code/dotfiles/bash/scripts"

# Set up case-insensitivity (from: https://askubuntu.com/q/87061/1039153):
# If ~/.inputrc doesn't exist yet: First include the original /etc/inputrc
# so it won't get overridden
if [ ! -a ~/.inputrc ]; then
  if [ -f /etc/inputrc ]; then
    echo '$include /etc/inputrc' > ~/.inputrc
  fi
fi

# Add shell-option to ~/.inputrc to enable case-insensitive tab completion
# Set up auto-complete cycle (from: https://unix.stackexchange.com/a/447638/403042)
echo 'set completion-ignore-case On' >> ~/.inputrc
echo 'set show-all-if-ambiguous on' >> ~/.inputrc
echo 'set show-all-if-unmodified on' >> ~/.inputrc
echo 'set menu-complete-display-prefix on' >> ~/.inputrc
echo '"\t": menu-complete' >> ~/.inputrc

source "$BASHRC_PATH"

