# Espanso

This package manages Espanso configuration with GNU Stow. The package contains
Espanso's `config/` and `match/` directories directly, so the same package can
be stowed into Espanso's platform-specific configuration directory.

## Install

Run the appropriate command from the dotfiles repository.

### macOS

Espanso's default configuration directory is
`~/Library/Application Support/espanso`:

```bash
stow --target "$HOME/Library/Application Support/espanso" espanso
```

### Windows (PowerShell)

Espanso's default configuration directory is `%APPDATA%\espanso`:

```powershell
stow --target "$env:APPDATA/espanso" espanso
```

Run GNU Stow in a Windows environment where it can create Windows symlinks.
If symlink creation is denied, enable Windows Developer Mode or run the
terminal with the required permissions.

### Linux

Espanso uses `~/.config/espanso` by default:

```bash
stow --target "$HOME/.config/espanso" espanso
```

## Stow operations

Use the same target path for each operation:

```bash
stow -nvt "$TARGET" espanso   # preview
stow -Rvt "$TARGET" espanso  # install or refresh
stow -Dvt "$TARGET" espanso  # uninstall
```

## Use

In a Chrome text field, type `;prbot` to open Espanso's Search Bar. Search by
command name or keyword, select an entry, and press Enter to paste it.

The default Search Bar shortcut (Option+Space on macOS, Alt+Space on Windows)
remains available. The PR Bot matches are only included in Chrome's active
Espanso configuration.

The macOS filter uses Chrome's application identifier
`com.google.Chrome`; the Windows filter matches `chrome.exe`.

If you already have an Espanso `config/default.yml`, merge the
`search_trigger: ";prbot"` setting rather than overwriting your existing
settings.
