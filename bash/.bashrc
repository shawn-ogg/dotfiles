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
  "$bash_config_dir/functions.sh" \
  "$bash_config_dir/prompt.sh"; do
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
  "$bash_config_dir/local.sh"; do
  # shellcheck source=/dev/null
  [[ -r "$bash_config" ]] && source "$bash_config"
done

unset bash_config
unset bash_config_dir
unset bash_platform