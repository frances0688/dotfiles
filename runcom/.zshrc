# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  nvm-homebrew nvm
  gh brew pyenv-homebrew pyenv
  macos iterm2
  vscode
  colored-man-pages extract z
  1password
  docker docker-compose
)

source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.local/bin:$PATH"
