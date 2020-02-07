# TODO, check for an existing ~/.vimrc, or an existing init.vim
echo "Loading '$PWD/_vimrc' into three locations"
echo "source $PWD/_vimrc" >> ~/.config/nvim/init.vim
echo "source $PWD/_vimrc" >> ~/.vimrc
echo "source $PWD/_vimrc" >> ~/.ideavimrc
