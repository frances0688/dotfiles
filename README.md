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
| 3 | `brew bundle` (`install/Brewfile`) | CLI tools, libraries, and apps (see below) |
| 4 | Oh My Zsh install script | [Oh My Zsh](https://ohmyzsh.sh) (if missing) |
| 5 | Powerlevel10k clone | Theme to `$ZSH_CUSTOM/themes/powerlevel10k` |
| 6 | `nvm` / `pyenv` / `goenv` | Latest stable Node LTS, Python 3.x, and Go |
| 7 | `npm install -g mongosh` | MongoDB Shell via nvm Node |
| 8 | Symlinks | Dotfiles into `~` (see [Configuration](#configuration)) |
| 9 | Terminal fonts | FiraCode Nerd Font in iTerm2 + Cursor (automated) |
| 10 | Directory setup | `~/.nvm`, `~/.pyenv`, `~/.goenv`, 1Password agent symlink |

Existing regular files are backed up to `*.bak` before symlinking.

---

## Applications & packages

### GUI apps (Homebrew casks)

Installed via `install/Brewfile` (`brew bundle`):

| App | Cask |
|-----|------|
| 1Password | `1password` |
| 1Password CLI | `1password-cli` |
| Cursor | `cursor` |
| Docker Desktop | `docker-desktop` |
| Google Chrome | `google-chrome` |
| iTerm2 | `iterm2` |
| FiraCode Nerd Font | `font-fira-code-nerd-font` |

See [Terminal fonts](#terminal-fonts) — iTerm2 and Cursor are configured automatically during install.

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
| xz | `xz` | Compression (pyenv build dependency) |
| GNU getopt | `gnu-getopt` | CLI option parsing |
| autoconf | `autoconf` | Build configuration (pyenv) |
| brotli | `brotli` | Compression library |
| c-ares | `c-ares` | Async DNS library |
| ca-certificates | `ca-certificates` | SSL root certificates |
| gettext | `gettext` | i18n (nvm/pyenv dependency) |
| ICU4C | `icu4c@78` | Unicode library |
| oniguruma | `oniguruma` | Regex library (jq dependency) |
| protobuf | `protobuf` | Protocol buffers |
| readline | `readline` | Line editing (pyenv dependency) |
| MongoDB Database Tools | `mongodb/brew/mongodb-database-tools` | `mongodump`, `mongoimport`, etc. |
| GNU Stow | `stow` | Symlink management (optional tooling) |

**Excluded:** `mongodb-community`, `mysql`, `ncurses`, Homebrew `node`, Homebrew `mongosh`

### Runtimes (installed by `setup.zsh`)

| Runtime | Manager | Version |
|---------|---------|---------|
| Node.js | nvm | Latest LTS (`nvm install --lts --default`) |
| Python | pyenv | Latest stable 3.x |
| Go | goenv | Latest stable release |
| mongosh | npm | Global install via nvm Node |

### MongoDB

| Tool | Method | Notes |
|------|--------|-------|
| Database Tools | `brew bundle` via `mongodb/brew` tap | Installed from Brewfile |
| mongosh | `npm install -g mongosh` in `setup.zsh` | Uses **nvm Node**, not Homebrew `node` or `mongosh` |

The `mongodb/brew` tap is added and trusted during install.

---

## Terminal fonts

Powerlevel10k uses **Nerd Font icons**. This repo installs and configures **FiraCode Nerd Font** automatically.

### What gets automated

| Step | Script | Action |
|------|--------|--------|
| 1 | `brew bundle` | Installs `font-fira-code-nerd-font` cask |
| 2 | `install/configure-terminal-fonts.py` | Sets iTerm2 Default profile font |
| 3 | same | Installs iTerm2 Dynamic Profile (`config/iterm2/DynamicProfiles/dotfiles-font.json`) |
| 4 | same | Merges Cursor `terminal.integrated.fontFamily` into settings.json |
| 5 | `runcom/.p10k.zsh` | Enables `nerdfont-complete` mode for icons |

Run during every `install/setup.zsh` (including `make link`).

### Re-run font setup only

```bash
cd ~/.dotfiles
make fonts
# or
python3 install/configure-terminal-fonts.py
```

### After install

1. **Quit and reopen iTerm2** (required for plist changes)
2. **Open a new terminal tab in Cursor** (integrated terminal caches the font)

### Manual verification

| App | Expected setting |
|-----|------------------|
| **iTerm2** | Settings → Profiles → Text → Font → **FiraCode Nerd Font** (14 pt) |
| **Cursor** | `Cmd+,` → search **Terminal › Integrated: Font Family** → `'FiraCode Nerd Font', monospace` |

Or open Cursor settings JSON (`Cmd+Shift+P` → **Preferences: Open User Settings (JSON)**):

```json
"terminal.integrated.fontFamily": "'FiraCode Nerd Font', monospace",
"terminal.integrated.fontSize": 14
```

Reference copy: `config/cursor/settings.json`

### Troubleshooting empty icon boxes

Icons render as empty rectangles when the terminal is not using a Nerd Font:

1. Confirm install: `brew list --cask font-fira-code-nerd-font`
2. Re-run: `make -C ~/.dotfiles fonts`
3. Restart both terminals (see above)
4. Confirm `~/.p10k.zsh` is symlinked and sets `POWERLEVEL9K_MODE=nerdfont-complete`

Alternative font: `font-meslo-lg-nerd-font` (Powerlevel10k default) — update `install/fonts.conf` and re-run font setup.

---

## Configuration

All config files live in this repo and are symlinked into place by `install/setup.zsh`.

### Shell — `runcom/.zshrc` → `~/.zshrc`

- **Theme:** [Powerlevel10k](https://github.com/romkatv/powerlevel10k) with dst color palette (`runcom/.p10k.zsh`)
- **Font:** FiraCode Nerd Font (`font-fira-code-nerd-font` cask)
- **Colors:** magenta user, yellow host, bold blue path, green git/time, red errors/dirty git
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

Node, Python, Go, and mongosh are installed automatically during bootstrap.

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
make macos          # brew bundle + re-link configs + fonts + secret scan
make link           # re-link configs + fonts
make fonts          # iTerm2 + Cursor font setup only
```

---

## Repository structure

```
.dotfiles/
├── remote-install.zsh       # One-line install entry point
├── install/
│   ├── setup.zsh                      # Full bootstrap script
│   ├── Brewfile                       # Homebrew formulae and casks
│   ├── fonts.conf                     # Font name/size constants
│   ├── fonts.zsh                      # Font install helpers
│   └── configure-terminal-fonts.py    # iTerm2 + Cursor font automation
├── config/
│   ├── cursor/settings.json           # Cursor terminal font defaults
│   ├── iterm2/DynamicProfiles/        # iTerm2 font profile overlay
│   └── ssh/                           # SSH config (no private keys)
├── runcom/                            # .zshrc, .gitconfig, .p10k.zsh
├── oh-my-zsh/custom/        # OMZ plugins and snippets
├── local/bin/               # Personal scripts
├── bin/check-secrets        # Pre-commit secret scanner
└── Makefile                 # macOS maintenance targets
```

---

## Security

No SSH private keys, API tokens, or passwords are stored in this repository.

Run `bin/check-secrets` before committing to verify tracked files are clean.
