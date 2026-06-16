# dotfiles

Personal macOS developer setup, inspired by [webpro/dotfiles](https://github.com/webpro/dotfiles).

## One-line install (new Mac)

```bash
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/frances0688/dotfiles/trunk/remote-install.zsh)"
```

This clones to `~/.dotfiles` and runs the full bootstrap: Homebrew, apps, shell, and config symlinks.

## Manual install

```bash
git clone git@github.com:frances0688/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make macos
```

## What gets installed

**Homebrew formulae:** git, gh, jq, nvm, pyenv, goenv, wget

**Homebrew casks:** 1Password, 1Password CLI, Cursor, Docker, Google Chrome, iTerm2

**Shell:** Oh My Zsh with custom nvm/pyenv Homebrew plugins, GitHub SSH via 1Password

## After install (manual steps)

These are intentionally not automated — they involve secrets or account access:

1. **1Password:** Create an SSH key, enable the SSH agent, run `github-ssh-setup`
2. **GitHub CLI:** `gh auth login`
3. **Cursor:** Cmd+Shift+P → “Install 'cursor' command in PATH”

## Structure

```
.dotfiles/
├── install/          Brewfile + setup script
├── runcom/           Shell rc files (.zshrc, .gitconfig)
├── config/           App configs (ssh, etc.)
├── oh-my-zsh/custom/ OMZ plugins and snippets
├── local/bin/        Personal scripts
└── macos/            macOS preferences (optional)
```

## Security

No SSH private keys, API tokens, or passwords are stored in this repo. Run `bin/check-secrets` before committing.
