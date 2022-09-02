#!/bin/bash -x

#xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

exec >/tmp/${XDG_VTNR}_startx$$.log 2>&1

# Prefer /usr/local/bin
export PATH="/usr/local/bin:$PATH"
echo PATH: $PATH

test -d /usr/share/fonts/local && xset +fp /usr/share/fonts/local
xset fp rehash
xset -b # disable bell

# SSH_ENV=$HOME/.ssh/environment
# ssh-agent | grep -v echo > ${SSH_ENV}
# chmod 600 ${SSH_ENV}
# . ${SSH_ENV} > /dev/null

# https://wiki.archlinux.org/index.php/Display_Power_Management_Signaling#Prevent_screen_from_turning_off
#xset -dpms
#xset s off

if test -f /usr/lib/ssh/x11-ssh-askpass
then
	SSH_ASKPASS=/usr/lib/ssh/x11-ssh-askpass ssh-add < /dev/null
fi

if [ -d /etc/X11/xinit/xinitrc.d ]; then
	for f in /etc/X11/xinit/xinitrc.d/*; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi


sudo vhuit64 -n 2>/dev/null


#setxkbmap -model thinkpad -layout us -option caps:escape
#xset m 5 1


autocutsel -fork
autocutsel -selection PRIMARY -fork

redshift -l 49.30:8.70 &
x-www-browser &


#xautolock -time 10 -locker slock &
xss-lock -- /usr/bin/slock &

# https://bbs.archlinux.org/viewtopic.php?id=66453
xmodmap ~/.Xmodmap &&

udiskie --automount --no-notify --no-tray &
numlockx

picom & # compositor

(sleep 5; setxkbmap -model pc105 -layout us,de -option grp:shifts_toggle) &
(sleep 6; hp 2>/dev/null) &

if [[ $XDG_VTNR -eq 2 ]]; then
	export _JAVA_AWT_WM_NONREPARENTING=1
	export AWT_TOOLKIT=MToolkit
	wmname LG3D


	~/bin/dwm_status &
	exec dwm 2> ~/tmp/${XDG_VTNR}_dwm.log
else
	exec openbox-session 2> ~/tmp/${XDG_VTNR}_openbox.log
fi

