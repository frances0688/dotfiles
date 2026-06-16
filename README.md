# dotfiles

Personal macOS developer bootstrap, inspired by [webpro/dotfiles](https://github.com/webpro/dotfiles).

## One-line install

Clone to `~/.dotfiles` and run the full bootstrap:

```bash
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/frances0688/dotfiles/trunk/remote-install.zsh)"
```

## What the install does

`remote-install.zsh` clones this repo to `~/.dotfiles` (or pulls if it already exists), then runs `install/setup.zsh`, which:

| Step | How | What |
|------|-----|------|
| 1 | `xcode-select --install` | Xcode Command Line Tools |
| 2 | Homebrew install script | [Homebrew](https://brew.sh) (if missing) |
| 3 | `brew install --cask` | 1Password, iTerm2, Google Chrome |
| 4 | `brew bundle` (`install/Brewfile`) | CLI tools and remaining apps (see below) |
| 5 | Oh My Zsh install script | [Oh My Zsh](https://ohmyzsh.sh) (if missing) |
| 6 | Symlinks | Dotfiles into `~` (see [Configuration](#configuration)) |
| 7 | Directory setup | `~/.nvm`, `~/.pyenv`, 1Password agent symlink |

Existing regular files are backed up to `*.bak` before symlinking.

---

## Applications & packages

### GUI apps (Homebrew casks)

Installed explicitly in `install/setup.zsh`:

| App | Cask | Method |
|-----|------|--------|
| 1Password | `1password` | `brew install --cask` |
| iTerm2 | `iterm2` | `brew install --cask` |
| Google Chrome | `google-chrome` | `brew install --cask` |

Installed via `install/Brewfile` (`brew bundle`):

| App | Cask |
|-----|------|
| 1Password CLI | `1password-cli` |
| Cursor | `cursor` |
| Docker Desktop | `docker-desktop` |

### CLI tools (Homebrew formulae)

Installed via `install/Brewfile` (`brew bundle`):

| Tool | Formula | Purpose |
|------|---------|---------|
| Git | `git` | Version control |
| GitHub CLI | `gh` | GitHub from the terminal |
| jq | `jq` | JSON processing |
| nvm | `nvm` | Node.js version manager (via Homebrew) |
| pyenv | `pyenv` | Python version manager |
| goenv | `goenv` | Go version manager |
| wget | `wget` | File downloads |
| GNU Stow | `stow` | Symlink management (optional tooling) |

---

## Configuration

All config files live in this repo and are symlinked into place by `install/setup.zsh`.

### Shell — `runcom/.zshrc` → `~/.zshrc`

- **Theme:** robbyrussell
- **PATH:** `~/.local/bin`
- **Oh My Zsh plugins:**

| Plugin | Source | What it adds |
|--------|--------|--------------|
| `git` | OMZ built-in | Git aliases and completion |
| `nvm-homebrew` | custom | Homebrew nvm bridge + lazy load |
| `nvm` | OMZ built-in | Node version management |
| `gh` | OMZ built-in | GitHub CLI completion |
| `brew` | OMZ built-in | Homebrew aliases |
| `pyenv-homebrew` | custom | pyenv shims bootstrap |
| `pyenv` | OMZ built-in | Python version management |
| `macos` | OMZ built-in | macOS utilities (`tab`, `ofd`, etc.) |
| `iterm2` | OMZ built-in | iTerm2 integration |
| `vscode` | OMZ built-in | Cursor/VS Code CLI aliases |
| `colored-man-pages` | OMZ built-in | Colored man pages |
| `extract` | OMZ built-in | `extract` for any archive |
| `z` | OMZ built-in | Directory jumping |
| `1password` | OMZ built-in | `opswd` password helper |
| `docker` | OMZ built-in | Docker completion and aliases |
| `docker-compose` | OMZ built-in | Docker Compose completion |

### Custom Oh My Zsh plugins — `oh-my-zsh/custom/` → `~/.oh-my-zsh/custom/`

| File | Purpose |
|------|---------|
| `github-ssh.zsh` | Routes `SSH_AUTH_SOCK` to 1Password agent; enables SSH commit signing |
| `plugins/nvm-homebrew/` | Symlinks Homebrew `nvm.sh` into `~/.nvm`; lazy-loads nvm |
| `plugins/pyenv-homebrew/` | Adds pyenv shims to `PATH` before OMZ pyenv plugin loads |

### Git — `runcom/.gitconfig` → `~/.gitconfig`

- User name and email
- Default branch: `trunk`
- Commit signing enabled (`gpg.format = ssh`, 1Password `op-ssh-sign`)
- Signing key set post-install by `github-ssh-setup` (not stored in this repo)

### SSH — `config/ssh/config` → `~/.ssh/config`

- 1Password SSH agent as `IdentityAgent`
- GitHub host entry (`git@github.com`)

No private keys are stored or installed.

### Scripts — `local/bin/` → `~/.local/bin/`

| Script | Purpose |
|--------|---------|
| `github-ssh-setup` | Configure Git commit signing and upload SSH key to GitHub via 1Password |

### Directories created

| Path | Purpose |
|------|---------|
| `~/.nvm` | Node versions (nvm) |
| `~/.pyenv` | Python versions (pyenv) |
| `~/.1password/agent.sock` | Symlink to 1Password SSH agent socket |

---

## After install (manual steps)

These require your accounts and secrets — they are not automated:

1. **1Password:** Sign in, create an SSH key, enable **Settings → Developer → Use the SSH agent**
2. **GitHub SSH & signing:** Run `github-ssh-setup`
3. **GitHub CLI:** Run `gh auth login`
4. **Cursor:** Cmd+Shift+P → “Install 'cursor' command in PATH”
5. **Node / Python / Go:** Install runtimes as needed (`nvm install --lts`, `pyenv install`, etc.)

---

## Manual install

If you already have Homebrew and prefer to clone yourself:

```bash
git clone git@github.com:frances0688/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
zsh install/setup.zsh
```

To refresh packages and re-link configs on an existing machine:

```bash
cd ~/.dotfiles
make macos          # brew bundle + re-link configs + secret scan
make link           # re-link configs only
```

---

## Repository structure

```
.dotfiles/
├── remote-install.zsh       # One-line install entry point
├── install/
│   ├── setup.zsh            # Full bootstrap script
│   └── Brewfile             # Homebrew formulae and casks
├── runcom/                  # Shell rc files (.zshrc, .gitconfig)
├── config/ssh/              # SSH config (no private keys)
├── oh-my-zsh/custom/        # OMZ plugins and snippets
├── local/bin/               # Personal scripts
├── bin/check-secrets        # Pre-commit secret scanner
└── Makefile                 # macOS maintenance targets
```

---

## Security

No SSH private keys, API tokens, or passwords are stored in this repository.

Run `bin/check-secrets` before committing to verify tracked files are clean.
