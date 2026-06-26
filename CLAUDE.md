# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow package that maps directly onto `$HOME`. Stow creates symlinks so that, e.g., `bash/.bashrc` becomes `~/.bashrc`.

## Stow workflow

```bash
# Apply / refresh a package
stow -R <package>

# Preview without applying
stow -nv <package>

# Remove a package's symlinks
stow -D <package>
```

Packages: `bash`, `git`, `hammerspoon`, `karabiner`, `keyd`, `nvim`, `nvim-lean`, `sesh`, `sway`, `tmux`, `wezterm`

## Architecture

### Bash (`bash/`)

`.bashrc` sources files from `~/.config/bash/` in this order:

1. `env.sh` → `aliases.sh` → `functions.sh` (cross-platform)
2. `env-<platform>.sh` → `aliases-<platform>.sh` (platform-specific: `macos`/`linux`/`windows`)
3. `env.local.sh`, `aliases.local.sh`, `functions.local.sh`, `prompt.local.sh`, `env.secrets.sh`, `local.sh` (gitignored local/secret overrides)
4. `prompt.sh`

`functions.sh` sets up a `PROMPT_COMMAND` hook (`reload_config_if_needed_and_append_history`) that watches mtime on all env and alias files and auto-reloads them when changed, so edits propagate to all running shells on the next prompt. Also appends history to `~/.bash_history_global`.

Gitignored files (never commit): `*.local.sh`, `secrets.sh`, `env.secrets.sh`

### Neovim (`nvim/`)

Lazy.nvim-based config. Entry point: `init.lua` → `config/options`, `config/keymaps`, `config/lazy`. Plugins live in `lua/plugins/`. Leader is `<Space>`.

Key bindings: `<leader>ff` find files, `<leader>fg` live grep, `<leader>fb` buffers, `<leader>fr` recent files, `gd` definition, `gr` references, `K` hover, `<leader>ca` code action, `[d`/`]d` diagnostics, `gx` open URL under cursor.

`nvim-lean/` is an alternative minimal config optimized for Bash/Python/Markdown/YAML with LSP+Treesitter loaded only for real filetypes.

### Tmux (`tmux/`)

Prefix is `C-a`. Pane navigation: `C-h/j/k/l` (no prefix needed). Splits: `|` vertical, `-` horizontal. Session management via `sesh` (prefix `s`). Plugins managed by TPM (vendored at `tmux/.config/tmux/plugins/tpm/`). tmux-continuum auto-saves every 15 min and restores on startup.

### Hammerspoon (`hammerspoon/`) — macOS only

Hyper key = `Cmd+Ctrl+Alt+Shift` (remapped from Caps Lock via Karabiner). Key bindings:
- `Alt+1-0`: app launchers (Chrome, WezTerm, VSCode, Finder, Preview, PowerPoint, Excel, Teams, Outlook)
- `Hyper+W` then a letter: web modal (g=Google, c=ChatGPT, j=Jira, a=AWS, b=bookmarks, w=bookmark chooser)
- `Hyper+T` then a letter: Teams status (o=offline, a=available, d=dnd, b=busy, r=brb, w=away)
- `Hyper+Space` / `Hyper+S`: sesh session launcher
- `Cmd+H`: show hotkey cheatsheet
- Config auto-reloads on `.lua` file save in `~/dotfiles/hammerspoon/`

### Karabiner (`karabiner/`) — macOS only

Remaps Caps Lock → Hyper (Cmd+Ctrl+Alt+Shift). Complex modifications in `assets/complex_modifications/`. Edit `karabiner.json` directly; automatic backups are committed but are noise — the canonical config is `karabiner.json`.

### keyd (`keyd/`) — Linux only

`/etc/keyd/default.conf` applies to all keyboards. Caps Lock → `overload(hyper, esc)` (tap=Esc, hold=Hyper). `leftalt` → `command` layer for Mac-like Cmd+C/V/X clipboard shortcuts. Hyper+hjkl = arrow keys. Hyper+v/b/x/z/n/p/c forward to WezTerm as `Shift+Ctrl+Alt+Meta+<key>` for tmux shortcuts.

### Sway (`sway/`) — Linux/Wayland only

Minimal tiling WM config. `$mod` = Super. Terminal = WezTerm, browser = Chromium, launcher = fuzzel. Scripts in `.config/sway/scripts/` handle focus-or-launch, sesh popup, and multi-window app focusing.

### WezTerm (`wezterm/`)

Single `wezterm.lua`. Detects macOS vs Linux at runtime. On macOS: Cmd+C/V for clipboard; on Linux: Ctrl+C/V with Ctrl+Shift+C/V sending the actual control characters. Hyper+v/b/z/x/n/p/c send tmux prefix sequences. Right-click copies selection or pastes.
