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

source ~/.bashrc

