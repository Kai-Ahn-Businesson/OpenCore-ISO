#!/usr/bin/env bash
# Simple launcher for mkmaciso
set -e

MKMACISO_URL="https://raw.githubusercontent.com/LongQT-sea/mkmaciso/main/mkmaciso"
LOCAL_BIN="$HOME/.local/bin"
TARGET="$LOCAL_BIN/mkmaciso"
EXPORT_LINE='export PATH="$HOME/.local/bin:$PATH"'

# Install mkmaciso if missing
if [[ ! -f "$TARGET" ]]; then
    mkdir -p "$LOCAL_BIN"
    curl -fsSL "$MKMACISO_URL" -o "$TARGET"
    chmod +x "$TARGET"
fi

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    case "$SHELL" in
      */zsh)  RC="$HOME/.zprofile" ;;
      */bash) RC="$HOME/.bash_profile" ;;
      *)      RC="$HOME/.profile" ;;
    esac
    
    touch "$RC"
    grep -qxF "$EXPORT_LINE" "$RC" || printf '\n%s\n' "$EXPORT_LINE" >> "$RC"
fi

exec "$TARGET" "$@"
