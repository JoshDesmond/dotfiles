#!/bin/bash
# Encrypt SSH config from ~/.ssh/config to dotfiles

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$HOME/.ssh/config"
TEMP_FILE="$SCRIPT_DIR/config"
ENCRYPTED_FILE="$SCRIPT_DIR/config.enc"

cp "$SOURCE" "$TEMP_FILE"

read -s -p "Password: " PASSWORD
echo
read -s -p "Confirm Password: " PASSWORD2
echo

if [ "$PASSWORD" != "$PASSWORD2" ]; then
    echo "Passwords don't match"
    rm "$TEMP_FILE"
    exit 1
fi

openssl aes-256-cbc -salt -pbkdf2 -in "$TEMP_FILE" -out "$ENCRYPTED_FILE" -pass pass:"$PASSWORD"

rm "$TEMP_FILE"

echo "Encrypted ~/.ssh/config to config.enc"