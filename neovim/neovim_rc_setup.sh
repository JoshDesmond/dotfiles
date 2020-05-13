#!/bin/bash

if ! [ -x "$(command -v nvim)" ] ; then
	sudo apt-get -y install neovim
fi

pushd "${0%/*}"

SCRIPT_INIT_VIM=~/.config/nvim/init.vim
SCRIPT_VIMRC=~/.vimrc
SCRIPT_IDEAVIMRC=~/.ideavimrc

test_for_existing_file() {
	if [ -f "$1" ]; then
		echo "$1 already exists. Printing contents:"
		cat $1
		echo "Would you like to completely remove the file?"
		echo "(answering \"no\" will just append sourcing to the file)"
		select yn in "Yes" "No"; do
			case $yn in
				Yes ) rm $1; break;;
				No ) break;;
			esac
		done
	fi
}


test_for_existing_file $SCRIPT_INIT_VIM
test_for_existing_file $SCRIPT_VIMRC
test_for_existing_file $SCRIPT_IDEAVIMRC


echo "Loading '$PWD/_vimrc' into three locations"
echo "source $PWD/_vimrc" >> ~/.config/nvim/init.vim
echo "source $PWD/_vimrc" >> ~/.vimrc
echo "source $PWD/_vimrc" >> ~/.ideavimrc

popd
