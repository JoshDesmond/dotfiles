# Simple script to manage Cursor keybindings on Unix-like systems
# Usage: ./cursor_keybindings.sh [check|copy]

# Define dotfiles path (adjust if needed)
DOTFILES_PATH="$HOME/Code/dotfiles/cursor/keybindings.json"

# Common Cursor config locations to check
CURSOR_PATHS=(
    "$HOME/.config/Cursor/User/keybindings.json"
    "$HOME/.config/cursor/User/keybindings.json"
    "$HOME/.var/app/dev.cursor.Cursor/config/Cursor/User/keybindings.json"
)

# Find where Cursor stores its config
find_cursor_config() {
    for path in "${CURSOR_PATHS[@]}"; do
        if [ -f "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    # If not found, check parent directories exist
    for path in "${CURSOR_PATHS[@]}"; do
        parent_dir=$(dirname "$path")
        if [ -d "$parent_dir" ]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

# Main logic
CURSOR_PATH=$(find_cursor_config)

if [ -z "$CURSOR_PATH" ]; then
    echo "❌ Could not find Cursor config directory"
    echo "Checked locations:"
    for path in "${CURSOR_PATHS[@]}"; do
        echo "  - $path"
    done
    exit 1
fi

echo "📁 Found Cursor config at: $CURSOR_PATH"

# Check if dotfiles keybindings exists
if [ ! -f "$DOTFILES_PATH" ]; then
    echo "❌ No dotfiles keybindings found at: $DOTFILES_PATH"
    exit 1
fi

case "${1:-check}" in
    check)
        if [ -f "$CURSOR_PATH" ]; then
            if diff -q "$DOTFILES_PATH" "$CURSOR_PATH" > /dev/null; then
                echo "✅ Files are identical"
            else
                echo "⚠️  Files differ:"
                diff -u "$CURSOR_PATH" "$DOTFILES_PATH" | head -20
                echo ""
                echo "Run '$0 copy' to update Cursor config"
            fi
        else
            echo "⚠️  No Cursor keybindings file exists yet"
            echo "Run '$0 copy' to create it"
        fi
        ;;
    
    copy)
        # Create directory if needed
        mkdir -p "$(dirname "$CURSOR_PATH")"
        
        # Copy the file
        cp "$DOTFILES_PATH" "$CURSOR_PATH"
        
        if [ $? -eq 0 ]; then
            echo "✅ Successfully copied keybindings to Cursor"
        else
            echo "❌ Failed to copy keybindings"
            exit 1
        fi
        ;;
    
    *)
        echo "Usage: $0 [check|copy]"
        echo "  check - Compare dotfiles and Cursor keybindings (default)"
        echo "  copy  - Copy dotfiles keybindings to Cursor config"
        exit 1
        ;;
esac
