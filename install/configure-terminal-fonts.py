#!/usr/bin/env python3
"""Configure iTerm2 and Cursor to use FiraCode Nerd Font for Powerlevel10k."""

from __future__ import annotations

import json
import plistlib
import sys
from pathlib import Path

FONT_FAMILY = "FiraCode Nerd Font"
FONT_SIZE = 14
ITERM_FONT = f"{FONT_FAMILY} {FONT_SIZE}"
CURSOR_FONT = f"'{FONT_FAMILY}', monospace"

HOME = Path.home()
ITERM_PLIST = HOME / "Library/Preferences/com.googlecode.iterm2.plist"
CURSOR_SETTINGS = DOTFILES / "config/cursor/settings.json"
CURSOR_SETTINGS_LIVE = HOME / "Library/Application Support/Cursor/User/settings.json"
DYNAMIC_PROFILES_DIR = HOME / "Library/Application Support/iTerm2/DynamicProfiles"
DOTFILES = Path(__file__).resolve().parent.parent


def configure_iterm2_dynamic_profile() -> bool:
    src = DOTFILES / "config/iterm2/DynamicProfiles/dotfiles-font.json"
    if not src.exists():
        print(f"skip iTerm2 dynamic profile: {src} missing")
        return False

    DYNAMIC_PROFILES_DIR.mkdir(parents=True, exist_ok=True)
    dest = DYNAMIC_PROFILES_DIR / "dotfiles-font.json"
    dest.write_text(src.read_text())
    print(f"installed iTerm2 dynamic profile: {dest}")
    return True


def configure_iterm2_plist() -> bool:
    if not ITERM_PLIST.exists():
        print("skip iTerm2 plist: iTerm2 preferences not found")
        return False

    with ITERM_PLIST.open("rb") as handle:
        data = plistlib.load(handle)

    default_guid = data.get("Default Bookmark Guid")
    updated = 0
    for bookmark in data.get("New Bookmarks", []):
        if bookmark.get("Guid") == default_guid or bookmark.get("Name") == "Default":
            bookmark["Normal Font"] = ITERM_FONT
            bookmark["Non Ascii Font"] = ITERM_FONT
            bookmark["Use Non-ASCII Font"] = False
            bookmark["Use Bold Font"] = False
            bookmark["Use Italic Font"] = False
            updated += 1

    if updated == 0:
        print("warn iTerm2: no Default profile found in New Bookmarks")
        return False

    with ITERM_PLIST.open("wb") as handle:
        plistlib.dump(data, handle)

    print(f"updated iTerm2 Default profile font to: {ITERM_FONT}")
    return True


def configure_cursor_settings() -> bool:
    patch = {
        "terminal.integrated.fontFamily": CURSOR_FONT,
        "terminal.integrated.fontSize": FONT_SIZE,
    }

    CURSOR_SETTINGS.parent.mkdir(parents=True, exist_ok=True)
    CURSOR_SETTINGS_LIVE.parent.mkdir(parents=True, exist_ok=True)
    existing: dict = {}
    if CURSOR_SETTINGS.exists():
        try:
            existing = json.loads(CURSOR_SETTINGS.read_text())
        except json.JSONDecodeError:
            print("warn Cursor: settings.json invalid JSON; overwriting font keys only")
            existing = {}

    existing.update(patch)
    CURSOR_SETTINGS.write_text(json.dumps(existing, indent=2) + "\n")
    if not CURSOR_SETTINGS_LIVE.exists() or not CURSOR_SETTINGS_LIVE.is_symlink():
        CURSOR_SETTINGS_LIVE.symlink_to(CURSOR_SETTINGS)
    print(f"updated Cursor terminal font to: {CURSOR_FONT} ({FONT_SIZE}pt)")
    return True


def main() -> int:
    results = [
        configure_iterm2_dynamic_profile(),
        configure_iterm2_plist(),
        configure_cursor_settings(),
    ]
    if results[-1]:
        print("terminal font configuration complete")
        print("restart iTerm2 and open a new Cursor terminal tab")
        return 0

    print("error: failed to configure Cursor terminal font", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
