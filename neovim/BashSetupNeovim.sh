#!/bin/bash

SCRIPT_INIT_VIM=~/.config/nvim/init.vim
SCRIPT_VIMRC=~/.vimrc
SCRIPT_IDEAVIMRC=~/.ideavimrc

test_for_existing_file() {
	if [ -f "$1" ]; then
		echo "$1 already exists. Printing contents and exiting script."
		cat $1
		# TODO delete files if they exist
		exit 2
	fi
}


test_for_existing_file $SCRIPT_INIT_VIM
test_for_existing_file $SCRIPT_VIMRC
test_for_existing_file $SCRIPT_IDEAVIMRC


echo "Loading '$PWD/_vimrc' into three locations"
echo "source $PWD/_vimrc" >> ~/.config/nvim/init.vim
echo "source $PWD/_vimrc" >> ~/.vimrc
echo "source $PWD/_vimrc" >> ~/.ideavimrc

