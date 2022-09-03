# dotfiles

use:

    git init --bare $HOME/.myconf
    alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    config config status.showUntrackedFiles no

where my ~/.dotfiles directory is a git bare repository. Then any file within the home folder can be versioned with normal commands like:

    config status
    config add .vimrc
    config commit -m "Add vimrc"
    config add .config/redshift.conf
    config commit -m "Add redshift config"
    config push

And so one…
T
You can replicate your home directory on a new machine using the following command:

git clone --separate-git-dir=~/.dotfiles /path/to/repo ~
