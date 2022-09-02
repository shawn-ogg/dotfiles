#!/bin/sh
if [ $# -ge 1 ]; then
        game="$(which $1)"
        openbox="$(which openbox)"
        tmpgame="/tmp/tmpgame.sh"
        DISPLAY=:2.0
        echo -e "${openbox} &\n${game}" > ${tmpgame}
        echo "starting ${game}"
        xinit ${tmpgame} -- :${XDG_VTNR} vt${XDG_VTNR} -keeptty -nolisten tcp || exit 1
        #xinit ${openbox} -- :2 vt7 -keeptty -nolisten tcp || exit 1
	#exec /usr/bin/X -nolisten tcp vt${XDG_VTNR} "${@}"
else
        echo "not a valid argument"
fi
