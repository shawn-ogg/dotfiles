# dotfiles

This repo is managed with GNU Stow.

## Bash

The Bash package lives under `bash/` and is designed to be XDG-friendly:

```text
bash/
├── .bash_profile
├── .bashrc
├── .inputrc
├── .profile
└── .config/
	└── bash/
		├── aliases.sh
		├── aliases-linux.sh
		├── aliases-macos.sh
		├── aliases-windows.sh
		├── env.sh
		├── env-linux.sh
		├── env-macos.sh
		├── env-windows.sh
		├── functions.sh
		└── prompt.sh
```

Install or refresh the package:

```bash
cd ~/dotfiles
stow -R bash
```

Preview changes before applying them:

```bash
cd ~/dotfiles
stow -nv bash
```

Remove the package:

```bash
cd ~/dotfiles
stow -D bash
```

Machine-local or secret overrides should go in gitignored files under `.config/bash/`, for example:

- `env.local.sh`
- `aliases.local.sh`
- `secrets.sh`
- `local.sh`

Those files are sourced automatically when present, but are not tracked by git.


## Optional SAP work integration

The SAP calendar status script is kept in the separate `sap/` Stow package. It is
not enabled by default. On a work machine, install it with:

```bash
cd ~/dotfiles
stow sap
```

Set `ENABLE_SAP_INTEGRATION=1` in the gitignored
`~/.config/bash/env.local.sh` to enable the calendar status display. Leave it
unset or set it to `0` to disable it. The script reads the SAP wiki bearer token
from `WAT`; keep that token in your private environment/secrets file, never in Git.
