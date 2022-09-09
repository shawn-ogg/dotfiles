export PATH
PATH="$HOME/bin:$PATH"

export EDITOR=vim
export VISUAL=vim
export BROWSER=firefox

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ -z $DISPLAY ]] && [[ -n $XDG_VTNR ]]; then
  if [[ $XDG_VTNR -le 3 ]]; then
    mkdir -p ~/xorg/$XDG_VTNR
    xlog=~/xorg/$XDG_VTNR/$(date +%s).log
    #read -p "Start Xorg? " -n 1 -r
    #echo    # (optional) move to a new line
    #if [[ $REPLY =~ ^[Yy]$ ]]
    #then
    exec xinit -- :$XDG_VTNR vt$XDG_VTNR -keeptty -nolisten tcp > "$xlog" 2>&1
    #fi
  fi
fi
