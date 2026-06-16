# Bridge Homebrew nvm with OMZ nvm plugin: store versions in ~/.nvm,
# load nvm.sh from Homebrew via symlink the plugin expects.
zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:plugins:nvm' autoload yes
zstyle ':omz:plugins:nvm' silent-autoload yes

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
mkdir -p "$NVM_DIR"

NVM_HOMEBREW="${NVM_HOMEBREW:-${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null)}/opt/nvm}"
if [[ -d "$NVM_HOMEBREW" && ! -e "$NVM_DIR/nvm.sh" ]]; then
  ln -sf "$NVM_HOMEBREW/nvm.sh" "$NVM_DIR/nvm.sh"
fi
