# dotfiles
dotfiles managed by homeshick

# Get a fancy vim with one command :-)
```
curl -fLo ~/.vimrc https://raw.githubusercontent.com/shawn-ogg/dotfiles/master/home/.vimrc
```

The next time you start vim it will install a bunch of plugins.
###There are two special cases:
* The YouCompleteMe plugin is not installed by default (because it has to compile stuff)
  ```
  vim +InstallYCM
  ```
* You can install a nice bash prompt with this:
  ```
  vim  +InstallBashPrompt +qa && source ~/.bashrc
  ```
  
Some handy oneliner:
```
# minimal
curl -fLo ~/.vimrc https://raw.githubusercontent.com/shawn-ogg/dotfiles/master/home/.vimrc && vim +PlugInstall +qa

# with ycm
curl -fLo ~/.vimrc https://raw.githubusercontent.com/shawn-ogg/dotfiles/master/home/.vimrc && vim +PlugInstall +InstallYCM +qa 

# get me a fancy bash prompt:
curl -fLo ~/.vimrc https://raw.githubusercontent.com/shawn-ogg/dotfiles/master/home/.vimrc && vim +PlugInstall +InstallBashPrompt +qa && [ -n "$BASH" ] && source ~/.bashrc

# Full hog
curl -fLo ~/.vimrc https://raw.githubusercontent.com/shawn-ogg/dotfiles/master/home/.vimrc && vim +PlugInstall +InstallYCM +InstallBashPrompt +qa && [ -n "$BASH" ] && source ~/.bashrc
```
