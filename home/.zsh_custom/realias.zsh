# use the realias command to manage this file!
#
ALIAS_FILE="$ZSH_CUSTOM/realias.zsh"
alias realias='$EDITOR "$ALIAS_FILE"; unalias -a; source "$HOME/.zshrc"'

# the aliases follow here:
alias ops-tmux="tmux new-session -A -s ops"
alias dev-tmux="tmux new-session -A -s dev"
