#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source ~/liquidprompt/liquidprompt

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/projects
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/bin/virtualenvwrapper.sh

[[ -e ~/.aliases ]] && . ~/.aliases
alias realias='vim ~/.aliases && . ~/.aliases'
alias reload='. ~/.bashrc'
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

#PS1='[\u@\h \W]\$ '

#alacritty() { command alacritty ${XEMBED:+--embed="$XEMBED"}; }

