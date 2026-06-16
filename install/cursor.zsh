#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
CURSOR_SETTINGS_SRC="$DOTFILES_DIR/config/cursor/settings.json"
CURSOR_EXTENSIONS_FILE="$DOTFILES_DIR/config/cursor/extensions.txt"
CURSOR_PLUGINS_FILE="$DOTFILES_DIR/config/cursor/plugins.json"

log() { print -P "%F{green}==>%f $*"; }
warn() { print -P "%F{yellow}==>%f $*"; }

backup_if_regular_file() {
  local target="$1"
  if [[ -f "$target" && ! -L "$target" ]]; then
    mv "$target" "${target}.bak"
    warn "Backed up existing file to ${target}.bak"
  fi
}

link_cursor_settings() {
  log "Linking Cursor settings..."
  mkdir -p "$CURSOR_USER_DIR"
  backup_if_regular_file "$CURSOR_USER_DIR/settings.json"
  ln -sfn "$CURSOR_SETTINGS_SRC" "$CURSOR_USER_DIR/settings.json"
}

install_cursor_extensions() {
  if [[ ! -f "$CURSOR_EXTENSIONS_FILE" ]]; then
    warn "No Cursor extensions list at $CURSOR_EXTENSIONS_FILE"
    return 0
  fi

  if ! command -v cursor &>/dev/null; then
    warn "cursor CLI not found; skipping extension install."
    warn "In Cursor: Cmd+Shift+P → \"Install 'cursor' command in PATH\", then re-run make cursor"
    return 0
  fi

  log "Installing Cursor extensions..."
  local extension failed=0
  while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -z "$extension" || "$extension" == \#* ]] && continue
    if cursor --install-extension "$extension" &>/dev/null; then
      print "  installed $extension"
    else
      warn "  failed $extension (may be unavailable on Open VSX)"
      failed=$((failed + 1))
    fi
  done < "$CURSOR_EXTENSIONS_FILE"

  if (( failed > 0 )); then
    warn "$failed extension(s) could not be installed automatically."
  fi
}

print_cursor_plugin_instructions() {
  if [[ ! -f "$CURSOR_PLUGINS_FILE" ]]; then
    return 0
  fi

  log "Cursor plugins to enable manually:"
  python3 - "$CURSOR_PLUGINS_FILE" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)

marketplace = data.get("marketplace", "cursor-public")
for plugin in data.get("plugins", []):
    print(f"  - {plugin} ({marketplace})")
PY
  warn "Enable these in Cursor Settings → Plugins after signing in."
}

link_cursor_settings
install_cursor_extensions
print_cursor_plugin_instructions

log "Cursor configuration complete."
