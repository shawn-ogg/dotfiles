# use the realias command to manage this file!
#
ALIAS_FILE="$ZSH_CUSTOM/realias.zsh"
alias realias='$EDITOR "$ALIAS_FILE"; unalias -a; source "$HOME/.zshrc"'

# the aliases follow here:
alias ops-tmux="tmux new-session -A -s ops"
alias dev-tmux="tmux new-session -A -s dev"

#bookmarks

goeff() {
    surf "https://golang.org/doc/effective_go.html" >/dev/null 2>&1 &
}
godoc() {
    surf "https://golang.org/doc/" >/dev/null 2>&1 &
}
gomod() {
    surf "https://golang.org/ref/spec" >/dev/null 2>&1 &
}
gomod() {
    surf "https://godoc.org/?q=$1" >/dev/null 2>&1 &
}

rmd() {
    if [ -z "$1" ]; then
        pandoc | w3m -T text/html -o confirm_qq=false
    else
        pandoc $1 | w3m -T text/html -o confirm_qq=false
    fi
}

pydocs() {
    if [ -z "$1" ]; then
        surf "https://docs.python.org/3/?q=$1" >/dev/null 2>&1 &
    else
        surf "https://docs.python.org/3/search.html?q=$1" >/dev/null 2>&1 &
    fi
}

tmuxcs() {
    #url="https://gist.githubusercontent.com/andreyvit/2921703/raw/426c2adf4e4077d89c76519410f9ce13c53c6c26/tmux.md"
    url="https://gist.githubusercontent.com/MohamedAlaa/2961058/raw/ddf157a0d7b1674a2190a80e126f2e6aec54f369/tmux-cheatsheet.markdown"
    curl -fLs "$url" | rmd
}

