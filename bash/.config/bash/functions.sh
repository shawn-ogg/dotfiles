# shellcheck shell=bash

if [[ -z ${BASH_FUNCTIONS_SH_LOADED:-} ]]; then
  BASH_FUNCTIONS_SH_LOADED=1

  bash_file_mtime() {
    if [[ ! -e "$1" ]]; then
      return 1
    fi

    if stat -f %m "$1" >/dev/null 2>&1; then
      stat -f %m "$1"
    else
      stat -c %Y "$1"
    fi
  }

  bash_append_prompt_command() {
    local command_name="$1"

    if [[ -z "$PROMPT_COMMAND" ]]; then
      PROMPT_COMMAND="$command_name"
    elif [[ ";$PROMPT_COMMAND;" != *";$command_name;"* ]]; then
      PROMPT_COMMAND="$PROMPT_COMMAND; $command_name"
    fi
  }

  clipboard_copy() {
    if command -v pbcopy >/dev/null 2>&1; then
      pbcopy
    elif command -v wl-copy >/dev/null 2>&1; then
      wl-copy
    elif command -v xclip >/dev/null 2>&1; then
      xclip -selection clipboard
    else
      printf 'No clipboard copy command found\n' >&2
      return 1
    fi
  }

  clipboard_paste() {
    if command -v pbpaste >/dev/null 2>&1; then
      pbpaste
    elif command -v wl-paste >/dev/null 2>&1; then
      wl-paste
    elif command -v xclip >/dev/null 2>&1; then
      xclip -selection clipboard -o
    else
      printf 'No clipboard paste command found\n' >&2
      return 1
    fi
  }

  calc() {
    local result

    result="$(printf 'scale=10;%s\n' "$*" | bc --mathlib | tr -d '\\\n')"
    if [[ "$result" == *.* ]]; then
      printf '%s' "$result" | sed -e 's/^\./0./' -e 's/^-\./-0./' -e 's/0*$//;s/\.$//'
    else
      printf '%s' "$result"
    fi
    printf '\n'
  }

  bash_alias_files=(
    "${XDG_CONFIG_HOME:-$HOME/.config}/bash/aliases.sh"
    "${XDG_CONFIG_HOME:-$HOME/.config}/bash/aliases.local.sh"
  )
  declare -Ag bash_alias_mtimes=()

  reload_aliases_if_needed_and_append_history() {
    local alias_file
    local mtime

    for alias_file in "${bash_alias_files[@]}"; do
      mtime=$(bash_file_mtime "$alias_file" 2>/dev/null) || continue
      if [[ ${bash_alias_mtimes["$alias_file"]:-} != "$mtime" ]]; then
        # shellcheck source=/dev/null
        source "$alias_file"
        bash_alias_mtimes["$alias_file"]="$mtime"
      fi
    done

    history -a
    history 1 >>~/.bash_history_global
  }

  getlast() {
    fc -ln "$1" "$1" | sed '1s/^[[:space:]]*//'
  }

  r() {
    local page

    page=$(fd .md | fzf --style full --preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}') || return
    mdn "$page"
  }

  venv() {
    # shellcheck source=/dev/null
    . "$(gum choose ~/.venv/*/bin/activate)"
  }

  dl() {
    local target
    local action
    local dest="${1:-.}"

    target=$(
      /bin/ls -td ~/Downloads/* 2>/dev/null |
        head -50 |
        fzf \
          --prompt='Downloads > ' \
          --preview='
              if [ -d {} ]; then
                  eza --tree --level=2 {} | head -200
              else
                  file {}
                  echo
                  bat --style=numbers --color=always --line-range=:200 {} 2>/dev/null
              fi
          '
    ) || return

    action=$(
      printf 'edit\nopen\ncopy\nmove\nextract\ncat\nreveal\n' |
        fzf --prompt='Action > '
    ) || return

    case "$action" in
    copy|move|extract)
      if [[ -n "$1" ]]; then
        dest=$(zoxide query "${1:-.}" 2>/dev/null || echo "$1")
      else
        dest=$(
          {
            pwd
            zoxide query -l
          } | awk '!seen[$0]++' |
            fzf --prompt='Destination > '
        ) || return
      fi
      ;;
    esac

    case "$action" in
    edit)
      nvim "$target"
      ;;
    open)
      if command -v open >/dev/null 2>&1; then
        open "$target"
      elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$target"
      fi
      ;;
    copy)
      cp -R "$target" "$dest"
      ;;
    move)
      mv "$target" "$dest"
      ;;
    extract)
      case "$target" in
      *.zip)
        unzip "$target" -d "$dest"
        ;;
      *.tar.gz|*.tgz)
        tar xzf "$target" -C "$dest"
        ;;
      *.tar.bz2)
        tar xjf "$target" -C "$dest"
        ;;
      *.tar.xz)
        tar xJf "$target" -C "$dest"
        ;;
      *.tar)
        tar xf "$target" -C "$dest"
        ;;
      *)
        printf 'Do not know how to extract: %s\n' "$target"
        ;;
      esac
      ;;
    cat)
      bat "$target"
      ;;
    reveal)
      if command -v open >/dev/null 2>&1; then
        open -R "$target"
      elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$(dirname "$target")"
      fi
      ;;
    esac
  }

  zh() {
    local dir

    dir="$(tmux display-message -p '#{session_path}' 2>/dev/null)"

    if [[ -n "$dir" ]]; then
      cd "$dir" || return
    else
      printf 'Not inside tmux\n'
      return 1
    fi
  }

  ghist() {
    local cmd

    cmd=$(
      tac ~/.bash_history_global |
        awk '!seen[$0]++' |
        fzf --tac --no-sort
    ) || return

    READLINE_LINE="$cmd"
    READLINE_POINT=${#cmd}
  }

  pbc() {
    if [[ $# -eq 0 ]]; then
      clipboard_copy
    else
      cat "$@" | clipboard_copy
    fi
  }

  pbcp() {
    realpath "$1" | clipboard_copy
  }

  bind -x '"\C-g":ghist'
fi