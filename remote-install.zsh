#!/usr/bin/env zsh
set -euo pipefail

SOURCE="${DOTFILES_REPO:-git@github.com:frances0688/dotfiles.git}"
TARGET="${DOTFILES_DIR:-$HOME/.dotfiles}"

if [[ -d "$TARGET/.git" ]]; then
  print -P "%F{yellow}==>%f Dotfiles already cloned at $TARGET"
  print -P "%F{yellow}==>%f Pulling latest changes..."
  git -C "$TARGET" pull --ff-only
else
  print -P "%F{green}==>%f Cloning dotfiles to $TARGET..."
  git clone --branch trunk "$SOURCE" "$TARGET"
fi

exec zsh "$TARGET/install/setup.zsh"
