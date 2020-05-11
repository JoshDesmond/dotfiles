#!/bin/bash
# Sets up .bashrc

# TODO grep ~/.bashrc and check for "/.bash_personal" so you can know if it's already a thing
SCRIPT_GREP_RESULT=$(grep ".bash_personal_aliases" ~/.bashrc )

if [ -n "$SCRIPT_GREP_RESULT" ] ; then
	echo ".bashrc already seems to be configured. Outputing .bashrc tail:"
	echo "======== ~/.bashrc ========"
	tail ~/.bashrc
	echo "==========================="
	printf "\nExiting script\n"
	exit 0
fi



# printf "\n\n" >> ~/.bashrc
# printf "source $PWD/.bash_personal_aliases\n" >> ~/.bashrc
# printf "source $PWD/.bash_personal_config\n\n" >> ~/.bashrc

