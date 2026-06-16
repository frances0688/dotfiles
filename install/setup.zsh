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

install_packages() {
  log "Installing Homebrew packages and casks..."
  brew update
  if ! brew tap | rg -q '^mongodb/brew$'; then
    brew tap mongodb/brew
  fi
  brew trust mongodb/brew 2>/dev/null || true
  brew bundle --file="$DOTFILES_DIR/install/Brewfile"
}

install_mongosh() {
  log "Installing mongosh via npm (uses nvm Node, not Homebrew node)..."
  load_nvm

  if ! command -v node &>/dev/null; then
    warn "Node not available; skipping mongosh install."
    return 0
  fi

  npm install -g mongosh
}

load_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  mkdir -p "$NVM_DIR"
  local nvm_prefix="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null)}/opt/nvm"
  if [[ -d "$nvm_prefix" && ! -e "$NVM_DIR/nvm.sh" ]]; then
    ln -sf "$nvm_prefix/nvm.sh" "$NVM_DIR/nvm.sh"
  fi
  local nvm_sh="${NVM_HOMEBREW:-$nvm_prefix/nvm.sh}"
  [[ -s "$nvm_sh" ]] && . "$nvm_sh"
}

load_pyenv() {
  export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
  export PATH="$PYENV_ROOT/bin:$PATH"
  command -v pyenv &>/dev/null || return 1
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
}

load_goenv() {
  export GOENV_ROOT="${GOENV_ROOT:-$HOME/.goenv}"
  export PATH="$GOENV_ROOT/bin:$PATH"
  command -v goenv &>/dev/null || return 1
  eval "$(goenv init -)"
}

install_runtimes() {
  log "Installing latest stable Node.js (nvm LTS)..."
  load_nvm
  nvm install --lts --default

  log "Installing latest stable Python (pyenv)..."
  load_pyenv
  local latest_python
  latest_python="$(pyenv install --list | rg -E '^\s+3\.\d+\.\d+$' | tr -d ' ' | tail -1)"
  pyenv install -s "$latest_python"
  pyenv global "$latest_python"

  log "Installing latest stable Go (goenv)..."
  load_goenv
  local latest_go
  latest_go="$(goenv install --list | rg -E '^\s+\d+\.\d+\.\d+\s*$' | tr -d ' ' | tail -1)"
  goenv install -s "$latest_go"
  goenv global "$latest_go"
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

install_powerlevel10k() {
  local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  mkdir -p "${theme_dir:h}"

  if [[ -d "$theme_dir/.git" ]]; then
    log "Updating Powerlevel10k theme..."
    git -C "$theme_dir" pull --ff-only 2>/dev/null || true
    return 0
  fi

  log "Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
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

link_cursor_settings() {
  local src="$DOTFILES_DIR/config/cursor/settings.json"
  local dest="$HOME/Library/Application Support/Cursor/User/settings.json"
  if [[ ! -f "$src" ]]; then
    return 0
  fi
  log "Configuring Cursor terminal font..."
  mkdir -p "${dest:h}"
  if [[ ! -f "$dest" ]]; then
    cp "$src" "$dest"
    return 0
  fi
  if ! rg -q 'terminal.integrated.fontFamily' "$dest" 2>/dev/null; then
    warn "Add terminal font to Cursor settings (see config/cursor/settings.json)"
  fi
}

setup_version_managers() {
  log "Creating version manager directories..."
  mkdir -p "$HOME/.nvm" "$HOME/.pyenv" "$HOME/.goenv"
  mkdir -p "$HOME/.1password"
  ln -sf "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" \
    "$HOME/.1password/agent.sock" 2>/dev/null || true
}

ensure_xcode_cli
ensure_homebrew
if ! $LINK_ONLY; then
  install_packages
  install_oh_my_zsh
  install_powerlevel10k
  setup_version_managers
  install_runtimes
  install_mongosh
fi
link_runcom
link_oh_my_zsh_custom
link_local_bin
link_ssh_config
link_cursor_settings
if ! $LINK_ONLY; then
  warn "Restart Cursor terminal tabs after font changes (kill and open new terminal)."
fi
if $LINK_ONLY; then
  setup_version_managers
fi

log "Bootstrap complete."
warn "Next steps: create a 1Password SSH key, then run: github-ssh-setup"
warn "Then authenticate GitHub CLI: gh auth login"
