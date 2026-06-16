DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
HOMEBREW_PREFIX := $(shell [ -d /opt/homebrew ] && echo /opt/homebrew || echo /usr/local)
export PATH := $(HOMEBREW_PREFIX)/bin:$(DOTFILES_DIR)/bin:$(HOME)/.local/bin:$(PATH)

.PHONY: all macos link packages check-secrets bootstrap fonts cursor

all: macos

macos: packages link check-secrets

packages:
	@command -v brew >/dev/null || (echo "Homebrew not found. Run: zsh remote-install.zsh" && exit 1)
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile

link:
	zsh $(DOTFILES_DIR)/install/setup.zsh --link-only

fonts:
	python3 $(DOTFILES_DIR)/install/configure-terminal-fonts.py

cursor:
	zsh $(DOTFILES_DIR)/install/cursor.zsh

check-secrets:
	$(DOTFILES_DIR)/bin/check-secrets

bootstrap:
	zsh $(DOTFILES_DIR)/remote-install.zsh
