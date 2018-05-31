#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without
# modifications, as long as this notice is preserved.
# -----------------------------------------------------------------------------
# Tested on Fedora 28, MacOS High Sierra

# Go to the directory of the script
cd "${0%/*}"

# Display help and exit if no args
if [ $# -eq 0 ]; then
  echo "Usage: setup.sh CMD1 [CMD2 [...]]"
  echo "Commands:"
  echo " vim: install vim"
  echo " fonts: install fonts"
  echo " tmux: install tmux"
  echo " ls: install ls colors"
  echo " zsh: install zsh and oh-my-zsh"
  exit 0
fi

platform=$(uname)
if [ $platform == "Darwin" ]; then
  echo "$platform"
elif [ $platform == "Linux" ]; then
  # In /etc/*release* we have information on the platform the script is running on
  # Where ID=fedora, split that line on equal sign and set distribution variable to fedora
  distribution=$(IFS='=' read -ra ARR <<< $(cat /etc/*release | grep "^ID=")&& echo ${ARR[1]})
  echo "$distribution $platform"
else
  echo "Unknown platform - exiting script."
  exit 1;
fi

_fonts() {
  echo " [setting up fonts...]"
  if [ "$platform" = "Darwin" ]; then
    cp fonts/Inconsolata-g.otf /Library/Fonts
  elif [ "$platform" = "Linux" ]; then
    sudo cp fonts/Inconsolata-g.otf /usr/local/share/fonts
    sudo fc-cache -f -v
  fi
  echo " [done]"
}

_tmux() {
  echo " [setting up tmux...]"
  if [ "$platform" = "Darwin" ]; then
      brew install tmux
  elif [ "$platform" = "Linux" ]; then
      if [ "$distribution" = "ubuntu"]; then
          sudo apt install -y tmux
      elif [ "$distribution" = "debian"]; then
          sudo apt-get install -y tmux
      elif [ "$distribution" = "fedora"]; then
          sudo dnf install -y tmux
      fi
  fi
  rm ~/.tmux.conf 2> /dev/null
  ln -rs tmux/.tmux.conf ~/.tmux.conf
  echo " [done]"
}

_zsh() {
    echo " [setting up zsh...]"
    if [ "$platform" = "Darwin" ]; then
        brew install zsh
        chsh -s $(which zsh)
    elif [ "$platform" = "Linux" ]; then
        if [ "$distribution" = "fedora" ]; then
            sudo dnf install zsh
            sudo chsh -s $(which zsh)
        elif [ "$distribution" = "debian" ]; then
            sudo apt-get install zsh
            sudo chsh -s $(which zsh)
        fi
    else
        echo "Unknown platform...exiting."
        exit 1
    fi

    # oh-my-zsh
    echo " [installing oh-my-zsh...]"
    curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh\
        | sh
    mkdir -p ~/.oh-my-zsh/custom/plugins 2> /dev/null
    mkdir -p ~/.oh-my-zsh/custom/themes 2> /dev/null
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git\
         ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    # .zshrc, color
    echo " [updating zsh config...]"
    rm ~/.zshrc 2> /dev/null
    ln -rs zsh/.zshrc ~/.zshrc
    ln -rs zsh/light.zsh-theme ~/.oh-my-zsh/custom/themes/light.zsh-theme
    ln -rs zsh/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh
    ln -rs zsh/zsh_highlight_style.zsh ~/.oh-my-zsh/custom/zsh_highlight_style.zsh
    echo " [done]"
}

_ls() {
  echo " [setting up ls colors...]"
  ln -rs config/.dircolors.db ~/.dircolors.db
  echo " [done]"
}

_vim() {
  echo " [setting up vim...]"
  read -p "Are you sure -- this will erase the old vim config -- (y/n)? " choice
  case "$choice" in
    y|Y )
      # Erase previous vim configuration
      rm ~/.vimrc 2> /dev/null
      rm -rf ~/.vim 2> /dev/null
      # Link downloaded files into current user's home directory
      ln -rs vim/.vimrc ~/.vimrc
      ln -rs vim/.vim ~/.vim
      # Install plugins
      mkdir -p vim/bundle 2> /dev/null
      git clone https://github.com/VundleVim/Vundle.vim.git\
        vim/.vim/bundle/Vundle.vim
      if [ "$platform" = "Darwin" ]; then #use MacVim; system python
        alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
      elif [ "$platform" = "Linux" ]; then
        if [ "$distribution" = "fedora" ]; then
          dnf install vim-enhanced python
        elif [ "$distribution" = "debian" ]; then
          sudo apt-get install vim python
        elif [ "$distribution" = "ubuntu" ]; then
          sudo apt-get install vim python
        fi
      else
        echo "Unknown distribution - exiting."
        exit 1
      fi
      vim -c :PluginInstall
      # Allow postponement of installing YouCompleteMe
      read -p "Install ycm now -- this might take a while -- (y/n)? " choice
      case "$choice" in
        y|Y )
          echo " [installing YouCompleteMe...]"

          if [ "$platform" = "Darwin" ]; then
              echo "Attempting to install on MacOS.  If this fails,"
              echo "more information at: https://valloric.github.io/YouCompleteMe/#installation"

            # Check if XCode is installed with Command Line Tools
            # this is required for C-family completion
            if [ type xcode-select >&- && xpath=$( xcode-select --print-path ) && \
              test -d "${xpath}" && text -x "${xpath}" ]; then

              echo "Requires the _latest_ version of MacVim..."
              echo "New versions are always available at: https://github.com/macvim-dev/macvim/releases/latest"
              # Symlink mvim script as vim
              ln -s /usr/local/bin/mvim vim

              echo "Installing / Upgrading cmake with Homebrew ... this may take "\
                "awhile..."
              # Assumes Homebrew is installed for easy installation of CMake
              brew install cmake && brew upgrade cmake

              ~/.vim/bundle/YouCompleteMe/install.py --clang-completer
            else
              echo "Xcode with Command Line Tools is not properly installed."
              echo "This is required for C-family completion.  To install, type:"
              echo "xcode-select --install"
            fi

          elif [ "$platform" = "Linux" ]; then

            # Assumes Fedora 21 and later
            if [ "$distribution" = "fedora" ]; then
              # Install development tools and CMake
              sudo dnf install automake gcc gcc-c++ kernel-devel cmake
              # Ensure Python headers are installed
              sudo dnf install python-devel python3-devel
              # Compile YCM _with_ semantic support for C-family languages
              ~/.vim/bundle/YouCompleteMe/install.py --clang-completer

            elif [ "$distribution" = "debian" ]; then
              sudo apt-get install gcc g++ cmake python-dev
              ~/.vim/bundle/YouCompleteMe/install.py --clang-completer
            elif [ "$distribution" = "ubuntu" ]; then
              sudo apt-get install gcc g++ cmake python-dev
              ~/.vim/bundle/YouCompleteMe/install.py --clang-completer
            else
              echo "Unknown distribution...exiting."
              exit 1
            fi
          else
            echo "Unknown platform (not Fedora or Debian)...exiting."
            exit 1
          fi
          ;;
      esac
      echo " [done]"
      return
      ;;
  esac
  echo "Not setting up vim."
}

for arg in "$@"; do
  case $arg in
    fonts) _fonts;;
    ls)  _ls;;
    tmux)  _tmux;;
    vim) _vim;;
    zsh) _zsh;;
    *)  echo "Error: unknown option $arg"
  esac
done
