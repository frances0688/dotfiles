# shellcheck shell=bash
# Terminal font helpers for Powerlevel10k + FiraCode Nerd Font.

DOTFILES_FONT_FAMILY="${DOTFILES_FONT_FAMILY:-FiraCode Nerd Font}"
DOTFILES_FONT_SIZE="${DOTFILES_FONT_SIZE:-14}"
DOTFILES_FONT_CASK="${DOTFILES_FONT_CASK:-font-fira-code-nerd-font}"

verify_nerd_font_installed() {
  if brew list --cask "$DOTFILES_FONT_CASK" &>/dev/null; then
    return 0
  fi
  if [[ -f "$HOME/Library/Fonts/FiraCodeNerdFont-Regular.ttf" ]]; then
    return 0
  fi
  warn "FiraCode Nerd Font not installed. Run: brew install --cask $DOTFILES_FONT_CASK"
  return 1
}

configure_terminal_fonts() {
  log "Configuring terminal fonts for Powerlevel10k..."
  verify_nerd_font_installed || return 0

  local py_script="$DOTFILES_DIR/install/configure-terminal-fonts.py"
  if [[ ! -x "$py_script" ]]; then
    chmod +x "$py_script"
  fi

  if ! python3 "$py_script"; then
    warn "Automatic font configuration failed — see README § Terminal fonts"
    return 1
  fi

  log "Terminal fonts configured (FiraCode Nerd Font ${DOTFILES_FONT_SIZE}pt)"
  warn "Quit and reopen iTerm2; open a new terminal tab in Cursor"
}

print_font_instructions() {
  cat <<EOF

Terminal font setup (Powerlevel10k icons):
  Font:   $DOTFILES_FONT_FAMILY ($DOTFILES_FONT_SIZE pt)
  iTerm2: automated via install/configure-terminal-fonts.py
  Cursor: automated via terminal.integrated.fontFamily in settings.json

If icons show as empty boxes:
  1. Confirm font is installed:  brew list --cask $DOTFILES_FONT_CASK
  2. Re-run font setup:          python3 ~/.dotfiles/install/configure-terminal-fonts.py
  3. Restart iTerm2 and open a new Cursor terminal tab
  4. iTerm2 manual check:        Settings → Profiles → Text → Font → $DOTFILES_FONT_FAMILY
  5. Cursor manual check:        Cmd+, → search "Terminal › Integrated: Font Family"

EOF
}
