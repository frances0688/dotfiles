#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export DOTFILES_DIR
LINK_ONLY=false
[[ "${1:-}" == "--link-only" ]] && LINK_ONLY=true

log() { print -P "%F{green}==>%f $*"; }
warn() { print -P "%F{yellow}==>%f $*"; }

ensure_xcode_cli() {
  if xcode-select -p &>/dev/null; then
    return 0
  fi
  log "Installing Xcode Command Line Tools..."
  xcode-select --install || true
  until xcode-select -p &>/dev/null; do sleep 5; done
}

ensure_homebrew() {
  if command -v brew &>/dev/null; then
    return 0
  fi
  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_gui_apps() {
  log "Installing 1Password, iTerm2, and Google Chrome (Homebrew casks)..."
  brew install --cask 1password iterm2 google-chrome
}

install_packages() {
  brew update
  install_gui_apps
  log "Installing remaining Homebrew packages..."
  brew bundle --file="$DOTFILES_DIR/install/Brewfile"
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    warn "Oh My Zsh already installed, skipping clone."
    return 0
  fi
  log "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

backup_if_regular_file() {
  local target="$1"
  if [[ -f "$target" && ! -L "$target" ]]; then
    mv "$target" "${target}.bak"
    warn "Backed up existing file to ${target}.bak"
  fi
}

link_runcom() {
  log "Linking runcom files..."
  for file in "$DOTFILES_DIR"/runcom/.*(N); do
    [[ "$(basename "$file")" == "." || "$(basename "$file")" == ".." ]] && continue
    local target="$HOME/$(basename "$file")"
    backup_if_regular_file "$target"
    ln -sfn "$file" "$target"
  done
}

link_oh_my_zsh_custom() {
  log "Linking Oh My Zsh custom files..."
  mkdir -p "$HOME/.oh-my-zsh/custom/plugins"

  for file in "$DOTFILES_DIR"/oh-my-zsh/custom/*.zsh(N); do
    backup_if_regular_file "$HOME/.oh-my-zsh/custom/$(basename "$file")"
    ln -sfn "$file" "$HOME/.oh-my-zsh/custom/$(basename "$file")"
  done

  for plugin in "$DOTFILES_DIR"/oh-my-zsh/custom/plugins/*(N); do
    backup_if_regular_file "$HOME/.oh-my-zsh/custom/plugins/$(basename "$plugin")"
    ln -sfn "$plugin" "$HOME/.oh-my-zsh/custom/plugins/$(basename "$plugin")"
  done
}

link_local_bin() {
  log "Linking local scripts..."
  mkdir -p "$HOME/.local/bin"
  for script in "$DOTFILES_DIR"/local/bin/*(N); do
    ln -sfn "$script" "$HOME/.local/bin/$(basename "$script")"
  done
}

link_ssh_config() {
  log "Linking SSH config..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  backup_if_regular_file "$HOME/.ssh/config"
  ln -sfn "$DOTFILES_DIR/config/ssh/config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
}

setup_version_managers() {
  log "Creating version manager directories..."
  mkdir -p "$HOME/.nvm" "$HOME/.pyenv"
  mkdir -p "$HOME/.1password"
  ln -sf "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" \
    "$HOME/.1password/agent.sock" 2>/dev/null || true
}

ensure_xcode_cli
ensure_homebrew
if ! $LINK_ONLY; then
  install_packages
  install_oh_my_zsh
fi
link_runcom
link_oh_my_zsh_custom
link_local_bin
link_ssh_config
setup_version_managers

log "Bootstrap complete."
warn "Next steps: create a 1Password SSH key, then run: github-ssh-setup"
warn "Then authenticate GitHub CLI: gh auth login"
