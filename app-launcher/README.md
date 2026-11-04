# Shared application launcher

The application shortcuts are defined once in `apps.ini` and consumed by
Hammerspoon on macOS and AutoHotkey v2 on Windows.

- `1` through `9` select positions 1 through 9.
- `0` selects position 10.
- Omit the platform key entirely to leave that position unassigned.
- macOS values are application bundle identifiers.
- Windows values are executable names or full executable paths.

The launcher is deliberately an absolute selector: if the target application is
already frontmost, the shortcut does nothing. Otherwise it activates an existing
window (restoring it if minimised), or launches the application if no window is
open. It never minimises or cycles through an application's windows.

## Windows

Run `windows.ahk` with AutoHotkey v2. Add it to the user's Startup folder or
create a shortcut to it there:

```powershell
explorer.exe shell:startup
```

The script resolves `apps.ini` relative to its own location, so keep the
repository directory structure intact.

## macOS

The Hammerspoon configuration reads `apps.ini` from
`~/dotfiles/app-launcher/apps.ini`. Reload Hammerspoon after changing it.
