# Cursor user config in dotfiles

Preferred setup: symlink Cursor's user config files to this directory. After a one-time link, `git pull` updates settings and keybindings immediately.

## Files

- `settings.json`
- `keybindings.json`

## Cursor user config locations

| OS | Path |
|---|---|
| Windows | `%APPDATA%\Cursor\User\` |
| Linux | `~/.config/Cursor/User/` |
| macOS | `~/Library/Application Support/Cursor/User/` |

These user-data paths are stable across Cursor app updates. Only the install directory changes; symlinks into AppData (or equivalent) keep working.

## Windows

Run from PowerShell in this directory (not WSL):

```powershell
.\powershell_cursor_symlinks.ps1 check
.\powershell_cursor_symlinks.ps1 link
```

Symlink creation needs **Developer Mode** (Settings → System → For developers) or an elevated (Administrator) PowerShell session.

### Legacy copy workflow

```powershell
.\powershell_cursor_keybindings.ps1 check
.\powershell_cursor_keybindings.ps1 copy
```

// TODO: Remove legacy copy workflow once all machines use powershell_cursor_symlinks.ps1.

## Linux / macOS

Manual symlinks:

```bash
ln -sf ~/code/dotfiles/cursor/settings.json ~/.config/Cursor/User/settings.json
ln -sf ~/code/dotfiles/cursor/keybindings.json ~/.config/Cursor/User/keybindings.json
```

Or use the copy workflow only:

```bash
./bash_cursor_keybindings.sh check
./bash_cursor_keybindings.sh copy
```

// TODO: Write bash_cursor_symlinks.sh (check|link) for Linux/macOS, mirroring powershell_cursor_symlinks.ps1. Remove bash_cursor_keybindings.sh once migrated.
