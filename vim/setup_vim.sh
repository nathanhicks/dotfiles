#!/bin/bash -x
# This script was written to configure my preferred terminal emulators and vim
# configuration on a freshly imaged machine.
#
# After running this script, just type (for example) ":colorscheme <TAB>"
# inside vim to see all the available colorschemes (I prefer solarized).
#
# Most of these colorthemes work best with a terminal emulator that supports 
# 256 colors, or in a GUI version of vim.

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

function codeschool {
  wget http://astonj.com/wp-content/uploads/2012/06/codeschool.vim2_.zip
  unzip codeschool.vim2_.zip
  rm codeschool.vim2_.zip
}

function grb256 {
  wget https://raw.githubusercontent.com/garybernhardt/dotfiles/master/.vim/colors/grb256.vim
}

function guardian {
  wget -O guardian.vim http://www.vim.org/scripts/download_script.php?src_id=4128
}

function distinguished {
  wget https://raw.githubusercontent.com/Lokaltog/vim-distinguished/develop/colors/distinguished.vim
}

function github {
  wget -O github.vim http://www.vim.org/scripts/download_script.php?src_id=12456
}

function jellybeans {
  wget https://raw.githubusercontent.com/nanotech/jellybeans.vim/master/colors/jellybeans.vim
}

function candy {
  wget -O candy.vim http://www.vim.org/scripts/download_script.php?src_id=817
}

function checkInstalled {
  if yum list installed $1 >/dev/null 2>&1; then
    echo -e "${GREEN}* $1 is already installed.${NC}"
  else
    read -p "$1 is not installed. Would you like to install it now?(y or n)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo yum install $1 
    else
      echo -e "${RED}* Skipping $1 installation...${NC}"
    fi
  fi
}

function checkGitInstall {
  read -r -p "Install $1? [y/N] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    pushd ~/.vim/bundle/
    git clone $2
    popd
  else
    echo -e "${RED}* Skipping $1 installation...${NC}"
  fi
}

function install_pathogen {
  read -r -p "Install pathogen (manages vim runtimepath)? [y/N] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Install Pathogen
    mkdir -p ~/.vim/autoload ~/.vim/bundle && \
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
  else
    echo -e "${RED}* Skipping pathogen installation...${NC}"
  fi
}

function install_solarized_terminator {
  read -r -p "Install the solarized colorscheme for terminator? [y/N] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Install solarized theme for Terminator terminal emulator
    git clone https://github.com/ghuntley/terminator-solarized.git
    cd terminator-solarized
    mkdir -p ~/.config/terminator/
    touch ~/.config/terminator/config
    # if you want to replace current config:
    cp config ~/.config/terminator
    # if you want to append current config:
    #cat config >> ~/.config/terminator/config
  else
    echo -e "${RED}* Skipping solarized colorscheme for terminator installation...${NC}"
  fi
}

function install_vimrc {
  # for Bash >= version 3.2:
  read -r -p "Replace your existing vimrc file? [y/N] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    cp .vimrc ~/.vimrc
  else
    echo -e "${GREEN}* Your current vimrc file will be left unaltered.${NC}"
  fi
}

clear
echo "**********************************************************************"
echo "* VIM & Shell Customizer v0.1                                        *"
echo "* https://github.com/nathanhicks/dotfiles.git                        *"
echo "**********************************************************************"
echo "Now updating package database and upgrading packages..."
echo -e "${GREEN}"
sudo yum update && sudo yum upgrade
echo -e "${NC}"
echo "Installing Development Tool group..."
echo -e "${GREEN}"
sudo yum groupinstall "Development Tools"
echo -e "${NC}"

checkInstalled vim-enhanced #CLI vim
checkInstalled vim-x11 #gvim
checkInstalled terminator
install_pathogen
checkGitInstall NerdTree https://github.com/scrooloose/nerdtree.git
checkGitInstall Vim-Colors Solarized \
  git://github.com/altercation/vim-colors-solarized.git
install_solarized_terminator
install_vimrc

# Determine current username to build path to colorscheme directory
username=$( who am i | awk '{print $1}' )
colorscheme_dir="/home/$username/.vim/colors"

if [[ ! -d "$colorscheme_dir" ]]; then
  echo "${RED}* Making the $colorscheme_dir directory.${NC}"
  mkdir -p "$colorscheme_dir"
else
  echo -e "${GREEN}* $colorscheme_dir already exists.${NC}"
fi
echo "**********************************************************************"
echo "* Additional Colorthemes                                             *"
echo "**********************************************************************"

# List the colorschemes to install here:
declare -a themes=(\
  Quit \
  candy \
  codeschool \
  distinguished \
  jellybeans \
  github \
  grb256 \
  guardian \
  )
PS3="Select a theme to install: "
select theme in ${themes[*]};
do
  case $theme in
    "Quit")
      echo "Exiting script.\n"
      break
      ;;
    *)
      echo "Installing the $theme theme."
      eval ${theme}
      # install the colorschemes so vim or gvim can find them
      if [ -d "$colorscheme_dir" ]; then
        mv *.vim "$colorscheme_dir"
      fi
      ;;
    esac
done
