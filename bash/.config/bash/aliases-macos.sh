# shellcheck shell=bash

alias asconf='vim ~/.config/aerospace/aerospace.toml; aerospace reload-config'
alias wzconf='vim ~/.config/wezterm/wezterm.lua'
alias hsconf='vim ~/.hammerspoon/init.lua'

alias mount='diskutil mount'
alias umount='diskutil unmount'

alias ipi='ipconfig getifaddr en0'
alias ipe='curl ipinfo.io/ip'

alias ctags='$(brew --prefix)/bin/ctags'

ql() {
	qlmanage -p "$@" 2>/dev/null
}

alias maccy-disable='defaults write org.p0deje.Maccy ignoreEvents true'
alias maccy-enable='defaults write org.p0deje.Maccy ignoreEvents false'