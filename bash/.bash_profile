# shellcheck shell=bash

if [[ -f ~/.bashrc ]]; then
  # shellcheck source=/dev/null
  source ~/.bashrc
fi

if [[ -f ~/.profile ]]; then
  # shellcheck source=/dev/null
  source ~/.profile
fi