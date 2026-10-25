# shellcheck shell=bash

case $- in
*i*) ;;
*) return ;;
esac

bash_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/bash"

case "$(uname -s)" in
Darwin)
  bash_platform="macos"
  ;;
Linux)
  bash_platform="linux"
  ;;
MINGW*|MSYS*|CYGWIN*)
  bash_platform="windows"
  ;;
*)
  bash_platform=""
  ;;
esac

for bash_config in \
  "$bash_config_dir/env.sh" \
  "$bash_config_dir/aliases.sh" \
  "$bash_config_dir/functions.sh"; do
  # shellcheck source=/dev/null
  [[ -r "$bash_config" ]] && source "$bash_config"
done

if [[ -n "$bash_platform" ]]; then
  for bash_config in \
    "$bash_config_dir/env-$bash_platform.sh" \
    "$bash_config_dir/aliases-$bash_platform.sh"; do
    # shellcheck source=/dev/null
    [[ -r "$bash_config" ]] && source "$bash_config"
  done
fi

for bash_config in \
  "$bash_config_dir/env.local.sh" \
  "$bash_config_dir/aliases.local.sh" \
  "$bash_config_dir/functions.local.sh" \
  "$bash_config_dir/prompt.local.sh" \
  "$bash_config_dir/env.secrets.sh" \
  "$bash_config_dir/local.sh"; do
  # shellcheck source=/dev/null
  [[ -r "$bash_config" ]] && source "$bash_config"
done

# Optional SAP work integration. Set ENABLE_SAP_INTEGRATION=1 in the
# gitignored ~/.config/bash/env.local.sh to enable it.
export ENABLE_SAP_INTEGRATION="${ENABLE_SAP_INTEGRATION:-0}"
if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
  tmux set-environment -g ENABLE_SAP_INTEGRATION "$ENABLE_SAP_INTEGRATION" 2>/dev/null || true
fi

if [[ -r "$bash_config_dir/prompt.sh" ]]; then
  # shellcheck source=/dev/null
  source "$bash_config_dir/prompt.sh"
fi

unset bash_config
unset bash_config_dir
unset bash_platform
