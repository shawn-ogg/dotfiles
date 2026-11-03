# shellcheck shell=bash

# Homebrew on Linux (including WSL).
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  # shellcheck source=/usr/share/bash-completion/bash_completion
  source /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
  # shellcheck source=/etc/bash_completion
  source /etc/bash_completion
fi

if command -v dircolors >/dev/null 2>&1; then
  if [[ -r ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi
