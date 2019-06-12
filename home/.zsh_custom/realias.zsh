# use the realias command to manage this file!
#
ALIAS_FILE="$ZSH_CUSTOM/realias.zsh"
alias realias='$EDITOR "$ALIAS_FILE"; unalias -a; source "$HOME/.zshrc"'

# the aliases follow here:
alias ops-tmux="tmux new-session -A -s ops"
alias dev-tmux="tmux new-session -A -s dev"

#bookmarks

goeff() {
    dillo -f "https://golang.org/doc/effective_go.html" >/dev/null 2>&1 &
}
godoc() {
    dillo -f "https://golang.org/doc/" >/dev/null 2>&1 &
}
gomod() {
    dillo -f "https://golang.org/ref/spec" >/dev/null 2>&1 &
}
gomod() {
    dillo -f "https://godoc.org/?q=$1" >/dev/null 2>&1 &
}

rmd() {
    pandoc $1 | w3m -T text/html
}
