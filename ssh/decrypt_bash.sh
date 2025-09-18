#!/bin/bash
# Decrypt SSH config and copy to ~/.ssh/config

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENCRYPTED_FILE="$SCRIPT_DIR/config.enc"
DECRYPTED_FILE="$SCRIPT_DIR/config"
TARGET="$HOME/.ssh/config"

mkdir -p "$HOME/.ssh"

read -s -p "Password: " PASSWORD
echo

openssl aes-256-cbc -d -salt -pbkdf2 -in "$ENCRYPTED_FILE" -out "$DECRYPTED_FILE" -pass pass:"$PASSWORD"

cp "$DECRYPTED_FILE" "$TARGET"
rm "$DECRYPTED_FILE"

echo "Decrypted to ~/.ssh/config"