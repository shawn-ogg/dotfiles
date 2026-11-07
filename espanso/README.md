# Espanso

This package manages Espanso configuration using GNU Stow.

## Install

From the dotfiles repository:

```bash
stow -nv espanso   # preview
stow espanso       # install
stow -R espanso    # refresh
stow -D espanso    # uninstall
```

The package creates these paths under `~/.config/espanso/`:

- `config/default.yml` — sets `;prbot` as the Search Bar trigger.
- `config/chrome_macos.yml` — enables the PR Bot snippets in Google Chrome on macOS.
- `config/chrome_windows.yml` — enables the PR Bot snippets in Google Chrome on Windows.
- `match/_github-prbot.yml` — shared GitHub PR Bot command snippets.

## Use

In a Chrome text field, type `;prbot` to open Espanso's Search Bar, then search for a command by its label or search terms and press Enter to paste it.

The default Espanso Search Bar shortcut (Option+Space on macOS, Alt+Space on Windows) also remains available. The PR Bot matches are only loaded in Chrome.

On macOS, the Chrome filter uses the application identifier `com.google.Chrome`. On Windows, it matches the Chrome executable name `chrome.exe`.

If you already have an Espanso `config/default.yml`, merge the `search_trigger: ";prbot"` setting rather than overwriting your existing settings.
