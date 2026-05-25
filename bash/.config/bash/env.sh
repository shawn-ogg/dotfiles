# shellcheck shell=bash

pathadd() {
  if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
    PATH="$1${PATH:+":$PATH"}"
  fi
}

GPG_TTY=$(tty)
export GPG_TTY

export EDITOR="nvim"
export FCEDIT='nvim --clean'

set -o vi
set -o noclobber

shopt -s autocd
shopt -s cdspell
shopt -s dirspell
shopt -s globstar
shopt -s direxpand
shopt -s no_empty_cmd_completion
shopt -s cmdhist
shopt -s histappend
shopt -s histverify

histories_dir="$HOME/.histories"
mkdir -p "$histories_dir"

histfile_name="bash"
if command -v tmux >/dev/null 2>&1; then
  tmux_session_name=$(tmux display-message -p '#S' 2>/dev/null)
  if [[ -n "$tmux_session_name" ]]; then
    histfile_name="tmux-$tmux_session_name"
  fi
fi
HISTFILE="$histories_dir/$histfile_name"
export HISTFILE
unset histfile_name
unset tmux_session_name
unset histories_dir

HISTCONTROL="erasedups:ignoreboth"
export HISTCONTROL
export HISTIGNORE="?:??:&:[ ]*:exit:ls:bg:fg:history"
HISTSIZE=500000
HISTFILESIZE=100000
HISTTIMEFORMAT='%F %T '
export HISTTIMEFORMAT

for completion in "$HOME"/bin/completions/*; do
  if [[ -r "$completion" ]]; then
    # shellcheck source=/dev/null
    source "$completion"
  fi
done
unset completion

pathadd "$HOME/bin"
pathadd "$HOME/.local/bin"
pathadd "$HOME/go/bin"
pathadd "$HOME/.console-ninja/.bin"

export BAT_THEME="ansi"
export GH_HOST="github.tools.sap"

stty werase undef 2>/dev/null || true

if [[ -f ~/.bash_vault ]]; then
  # shellcheck source=/dev/null
  source ~/.bash_vault
fi

if [[ -z "$SSH_AUTH_SOCK" ]]; then
  eval "$(ssh-agent -s)" >/dev/null
  if declare -F vault-setup >/dev/null 2>&1; then
    vault-setup
  fi
fi