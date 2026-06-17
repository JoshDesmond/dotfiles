# Initial Setup Command Reference:
cp ~/.config/Cursor/User/keybindings.json ~/dotfiles/cursor/

# Linux / macOS / WSL (native Linux Cursor install):
cp ~/code/dotfiles/cursor/keybindings.json ~/.config/Cursor/User/keybindings.json
# Or from the cursor/ directory: ./bash_cursor_keybindings.sh copy

# Note, you might have to make the directory first:
cd ~/.config && mkdir Cursor && cd ./Cursor && mkdir User

# Windows (Cursor installed on Windows — run from PowerShell, not WSL):
# From the cursor/ directory:
#   .\powershell_cursor_keybindings.ps1 check
#   .\powershell_cursor_keybindings.ps1 copy
# Config location: %APPDATA%\Cursor\User\keybindings.json
