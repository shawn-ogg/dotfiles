# shellcheck shell=bash

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"

if [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
  # shellcheck source=/opt/homebrew/etc/profile.d/bash_completion.sh
  source /opt/homebrew/etc/profile.d/bash_completion.sh
else
  for completion in /opt/homebrew/etc/bash_completion.d/*; do
    if [[ -r "$completion" ]]; then
      # shellcheck source=/dev/null
      source "$completion"
    fi
  done
  unset completion
fi

export GROOVY_HOME="/opt/homebrew/opt/groovy/libexec"
export CLICOLOR=1
export LSCOLORS="ExFxBxDxCxegedabagacad"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=yes