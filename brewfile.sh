#!/bin/sh

brew update
brew upgrade --all || true

brew tap homebrew/dupes
brew tap homebrew/versions

brew install ack
brew install ant
brew install astyle
brew install autoconf
brew install autojump
brew install automake
brew install bash
brew install bash-completion
brew install cmigemo
brew install colordiff
brew install colorsvn
brew install convmv
brew install coreutils
brew install corkscrew
brew install cpanminus
brew install ctags
brew install direnv
brew install devtodo
brew install dos2unix
brew install exiftool
brew install fdupes
brew install figlet
brew install gcal
brew install gd
brew install gdbm
brew install gettext
brew install git
brew install git-extras
brew install git-flow
brew install --zsh-completion git-now
brew install global
brew install gnu-getopt
brew install gnu-sed --with-default-names
brew install go
brew install homebrew/dupes/grep --with-default-names
brew install gradle
brew install graphviz
brew install groovy
brew install help2man
brew install hub
brew install imagemagick
brew install jasper
brew install jenkins
brew install jetty8
brew install jpeg
brew install jq
brew install jsonpp
brew install lha
brew install libevent
brew install libffi
brew install libidn
brew install libpng
brew install libsigc++
brew install libssh2
brew install libtiff
brew install libtool
brew install libxml2
brew install libyaml
brew install lua
brew install lv
brew install maven-shell
brew install maven2
brew install mcrypt
brew install md5sha1sum
brew install memcache-top
brew install memcached
brew install mercurial
brew install mm-common
brew install mobile-shell
brew install neon
brew install ngrep
brew install nkf
brew install nmap
brew install node
brew install nvm
brew install oniguruma
brew install openssl
brew install ossp-uuid
brew install pcre
brew install pkg-config
brew install typesafe-activator # play
brew install pngcheck
brew install polipo
brew install postgresql
brew install proctools
brew install protobuf
brew install proxytunnel
brew install pstree
brew install python
brew install qt
brew install readline
brew install reattach-to-user-namespace
brew install rhino
brew install rlwrap
brew install ruby-build
brew install sonar
brew install sonar-runner
brew install spidermonkey
brew install sqlite
brew install ssh-copy-id
brew install sshrc
brew install subversion
brew install swig
brew install tcpflow
brew install tig
brew install tmux
brew install tokyo-cabinet
brew install tomcat
brew install tomcat6
brew install tree
brew install uncrustify
brew install vim
brew install visionmedia-watch
brew install w3m
brew install wget
brew install yuicompressor
brew install z
brew install --enable-etcdir zsh
brew install zsh-lovers
brew install docker-machine
brew install docker
brew install docker-compose
brew install docker-swarm
brew install docker-clean
brew install -v --HEAD xctool
brew install phantomjs
brew install htop
brew install wireshark
brew install qemu
brew install jigdo
brew install libvirt
brew install fping
brew install ddrescue
brew install ipcalc
brew install sipcalc
brew install mtr
brew install ranger
brew install dfc
brew install gnuplot
brew install freeradius-server
brew install pandoc
brew install html-xml-utils
brew install terraform
brew install ansible
brew install ansifilter
brew install daemontools
brew install source-highlight
brew install grepcidr
brew install minicom
brew install samba
brew install unrar
brew install unrar
brew install pwgen
brew install sf-pwgen
brew install iproute2mac
brew install shellcheck

brew tap homebrew/binary

# ricty
brew tap sanemat/font
brew install --powerline --vim-powerline ricty


# peco
brew tap peco/peco
brew install peco/peco/peco

# neovim
brew install neovim/neovim/neovim

# homebrew-cask
brew tap caskroom/cask
brew install caskroom/cask/brew-cask

brew tap caskroom/versions

brew cask install xquartz || true
brew cask install alfred || true
brew cask install appcleaner || true
brew cask install freemind || true
brew cask install google-chrome || true
brew cask install google-japanese-ime || true
brew cask install grandperspective || true
brew cask install iterm2 || true
brew cask install keyremap4macbook || true
brew cask install kobito || true
brew cask install codekit || true
brew cask install libreoffice || true
brew cask install pgadmin3 || true
brew cask install skitch || true
brew cask install sourcetree || true
brew cask install sublime-text || true
brew cask install vagrant || true
brew cask install xmarks-safari || true
brew cask install webstorm || true
brew cask install intellij-idea-ce || true
brew cask install cinch || true
brew cask install dash || true
brew cask install visual-studio-code || true
#brew cask install virtualbox || true
brew cask install oclint || true
brew cask install java || true # 1.8
brew cask install jsl || true

#brew cask install android-studio || true
#brew cask install appcode || true
brew cask install cheatsheet || true
brew cask install gimp || true
brew cask install evernote || true
brew cask install keepassx || true
brew cask install jxplorer || true
brew cask install android-file-transfer || true
brew cask install chefdk || true
brew cask install kitematic || true

# caskroom/versions
brew cask install macvim-kaoriya || true

#brew cleanup -s
