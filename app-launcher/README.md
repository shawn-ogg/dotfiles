# macOS application launcher

Application shortcuts are defined in `apps.ini` and consumed by Hammerspoon.

- `1` through `9` select positions 1 through 9.
- `0` selects position 10.
- Each `macos` value is an application bundle identifier.

Windows uses the native taskbar shortcuts (`Win+1` through `Win+0`) and does not need a separate launcher.

Hammerspoon reads `apps.ini` from `~/dotfiles/app-launcher/apps.ini`. Reload Hammerspoon after changing it.
