#!/usr/bin/env bash
# Wrapper launcher for mkmaciso
set -e

MKMACISO_URL="https://raw.githubusercontent.com/LongQT-sea/mkmaciso/main/mkmaciso"
LOCAL_BIN="$HOME/.local/bin"
TARGET="$LOCAL_BIN/mkmaciso"
ZSHRC="$HOME/.zshrc"
EXPORT_LINE='export PATH="$HOME/.local/bin:$PATH"'

# Install mkmaciso if missing
if [[ ! -f "$TARGET" ]]; then
    mkdir -p "$LOCAL_BIN"
    curl -fsSL "$MKMACISO_URL" -o "$TARGET"
    chmod +x "$TARGET"
fi

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    touch "$ZSHRC"
    grep -qxF "$EXPORT_LINE" "$ZSHRC" || echo "$EXPORT_LINE" >> "$ZSHRC"
fi

exec "$TARGET" "$@"
