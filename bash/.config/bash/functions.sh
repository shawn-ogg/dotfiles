# shellcheck shell=bash

  bash_file_signature() {
    [[ -r "$1" ]] || { printf 'missing'; return 0; }
    cksum < "$1"
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

  _bash_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/bash"

  bash_watched_files=(
    "$_bash_config_dir/env.sh"
    "$_bash_config_dir/aliases.sh"
    "$_bash_config_dir/functions.sh"
  )
  if [[ -n "${bash_platform:-}" ]]; then
    bash_watched_files+=(
      "$_bash_config_dir/env-$bash_platform.sh"
      "$_bash_config_dir/aliases-$bash_platform.sh"
    )
  fi
  bash_watched_files+=(
    "$_bash_config_dir/env.local.sh"
    "$_bash_config_dir/aliases.local.sh"
    "$_bash_config_dir/functions.local.sh"
    "$_bash_config_dir/prompt.local.sh"
    "$_bash_config_dir/env.secrets.sh"
    "$_bash_config_dir/local.sh"
  )
  declare -a bash_watched_signatures

  bash_update_config_signatures() {
    local i file
    for i in "${!bash_watched_files[@]}"; do
      file="${bash_watched_files[$i]}"
      bash_watched_signatures[$i]="$(bash_file_signature "$file")"
    done
  }

  bash_reload_config() {
    local file
    for file in "${bash_watched_files[@]}"; do
      [[ -r "$file" ]] || continue
      # shellcheck source=/dev/null
      source "$file" || {
        printf 'refresh: failed to source %s\n' "$file" >&2
        return 1
      }
    done
    bash_update_config_signatures
    if [[ -n "${ENABLE_SAP_INTEGRATION:-}" ]] &&
      command -v tmux >/dev/null 2>&1 &&
      tmux list-sessions >/dev/null 2>&1; then
      tmux set-environment -g ENABLE_SAP_INTEGRATION "$ENABLE_SAP_INTEGRATION" 2>/dev/null || true
    fi
    printf 'Bash configuration refreshed.\n'
  }

  refresh() {
    bash_reload_config
  }

  reload_config_if_needed_and_append_history() {
    local i file signature
    for i in "${!bash_watched_files[@]}"; do
      file="${bash_watched_files[$i]}"
      signature="$(bash_file_signature "$file")"
      if [[ ${bash_watched_signatures[$i]:-} != "$signature" ]]; then
        if [[ -r "$file" ]]; then
          # shellcheck source=/dev/null
          if source "$file"; then
            bash_watched_signatures[$i]="$(bash_file_signature "$file")"
            printf 'Reloaded Bash config: %s\n' "${file##*/}" >&2
          else
            printf 'Auto-refresh failed: %s\n' "$file" >&2
          fi
        else
          bash_watched_signatures[$i]="$signature"
        fi
      fi
    done

    history -a
    history 1 >>~/.bash_history_global
  }

  bash_update_config_signatures

  unset _bash_config_dir

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
      printf 'edit\nopen\ncopy\nmove\nextract\ncat\nreveal\npath\nclipboard\n' |
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
    path)
      printf '%s' "$target" | clipboard_copy
      printf 'Copied to clipboard: %s\n' "$target"
      ;;
    clipboard)
      if [[ -f "$target" ]]; then
        clipboard_copy < "$target"
        echo "Copied contents of: $target"
      else
        echo "Not a regular file: $target" >&2
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

gc() {
  local branch=${1:--}
  git checkout "$branch"
}
