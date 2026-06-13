# Initial Setup Command Reference:
cp ~/.config/Cursor/User/keybindings.json ~/dotfiles/cursor/

# Use this copy the files to a new system:
cp ~/code/dotfiles/cursor/keybindings.json ~/.config/Cursor/User/keybindings.json
# Or from the cursor/ directory: ./bash_cursor_keybindings.sh copy

# Note, you might have to make the directory first:
cd ~/.config && mkdir Cursor && cd ./Cursor && mkdir User

# Edit: Update, Looks like my laptop is using a
different location, ~/AppData/Roaming/Cursor/User
