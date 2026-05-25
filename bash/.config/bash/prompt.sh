# shellcheck shell=bash

bash_append_prompt_command reload_aliases_if_needed_and_append_history

if command -v tmux >/dev/null 2>&1 \
  && [[ -z "$TMUX" ]] \
  && [[ -z "$VSCODE_INJECTION" ]] \
  && [[ "$TERM_PROGRAM" != "vscode" ]]; then
  tmux attach || tmux
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"

  if declare -F _fzf_host_completion >/dev/null 2>&1; then
    _fzf_complete_ssh_notrigger() {
      FZF_COMPLETION_TRIGGER='' _fzf_host_completion
    }
    complete -o bashdefault -o default -F _fzf_complete_ssh_notrigger ssh
  fi
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi