#!/bin/bash

set -e

#
#             Configuration
# - - - - - - - - - - - - - - - - - - - - - -

brewInstalls='git grc coreutils ack findutils gnu-tar tmux htop-osx ctags nginx gnu-sed'

dotfiles_repo='git@github.com:mattmcmanus/dotfiles.git'
dotfiles_location="$HOME/.dotfiles"

# Apps to install
apps=(chrome virtualbox vagrant password dropbox sublimetext2 evernote firefox iterm2)

# URLs for app downloads
# Make sure all apps listed above have associated urls
vagrant_url='http://files.vagrantup.com/packages/64e360814c3ad960d810456add977fd4c7d47ce6/Vagrant.dmg' #1.1.5
chrome_url='https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg'
firefox_url='https://download.mozilla.org/?product=firefox-20.0&os=osx&lang=en-US'
dropbox_url='https://www.dropbox.com/download?plat=mac'
password_url='https://d13itkw33a7sus.cloudfront.net/dist/1P/mac/1Password-3.8.20.zip'
virtualbox_url='http://download.virtualbox.org/virtualbox/4.2.10/VirtualBox-4.2.10-84104-OSX.dmg'
sublimetext2_url='http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1.dmg'
evernote_url='http://www.evernote.com/about/download/get.php?file=EvernoteMac'
iterm2_url='https://iterm2.googlecode.com/files/iTerm2-1_0_0_20130319.zip'


# An array of various vagrant repos to checkout
vagrantRepos=('git@github.com:punkave/punkave-vagrant-lamp.git')

#
#     Functions make things easier!
# - - - - - - - - - - - - - - - - - - - - - -

function log {
  echo ""
  echo " ==> $1"
  echo ""
}

function installApp() {
  name=$1
  url=$2
  # A quick check to see if the app is already installed
  [ ! -n "`find /Applications -maxdepth 1 -iname *$name*`" ] && (
    shopt -s nullglob
  
    cd ~/Downloads/
    
    # We need to account for zips as well as dmgs
    [ "${url##*.}" == 'zip' ] && dest="$name.zip" || dest="$name.dmg"
    mountpoint="/Volumes/$name"

    log "Installing $name from $url to $dest"
    
    [ ! -e $dest ] && curl -L -o $dest "$url"
    
    if [ "${dest##*.}" == 'zip' ]; then
      unzip $dest -d /Applications/

    else
      hdiutil attach -mountpoint $mountpoint $dest
      # Test if there is a pkg or app file and run the appropriate installer
      cd $mountpoint
      [ -e "`echo *.pkg`" ] && sudo installer -package *.pkg -target /
      [ -e "`echo *.app`" ] && cp -R *.app /Applications/
      cd ~
      sleep 5
      hdiutil detach $mountpoint -force
    fi
    rm $HOME/Downloads/$dest

  ) || log "$name already installed"
}


#
#         Commence Installations
# - - - - - - - - - - - - - - - - - - - - - -

echo ''
echo '       * * * * * * * * * * * * * * INITIATING * * * * * * * * * * * * * * '
echo''
echo '	    __  __                                                  '
echo '	   / / / /_  ______  ___  _______                           '
echo '	  / /_/ / / / / __ \/ _ \/ _____/                     _     '
echo '	 / __  / /_/ / /_/ /  __/ / ____/__  ____  ___  _____(_)____'
echo '	/_/ /_/\__, / .___/\___/_/ / __/ _ \/ __ \/ _ \/ ___/ / ___/'
echo '	      /____/_/          / /_/ /  __/ / / /  __(__  ) (__  ) '
echo '	                        \____/\___/_/ /_/\___/____/_/____/  '                                                      
echo ''
echo '       * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * '


#0. Install XCode
# Not sure how to check this just yet


[ ! $(which brew) ] && (
  #log "Installing Homebrew"
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
  
  log "Installing goodies from homebrew"  
  brew update
  brew install $brewInstalls
)


[ ! -d $dotfiles_location ] && (
  log "Setting up your dotfiles repo"
  cd $HOME
  git clone $dotfiles_repo $dotfiles_location
  cd .dotfiles
  script/bootstrap
  source ~/.bash_profile
)

[ ! -d $HOME/.nvm ] && (
  log "Installing NVM"
  curl https://raw.github.com/creationix/nvm/master/install.sh | sh
  source ~/.bash_profile
  nvm install 0.10
)


log "Installing Apps"
for app in "${apps[@]}"
do
  installApp $app $(eval "echo \$${app}_url") # Ew
done

# 6. Cloning vagrant repos
log "Closing vagrant repos"
#mkdir -p ~/dev
#cd ~/dev/
#for repo in "${vagrantRepos[@]}"
#do
#  git clone $repo
#done


echo '       * * * * * * HYPERGENESIS REVELATION * * * * * * '
echo '               Hooray! Everything seems setup'
