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
brew install bash-completion
brew install cmigemo
brew install colordiff
brew install colorsvn
brew install convmv
brew install coreutils
brew install corkscrew
brew install cpanminus
brew install ctags
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
#brew install git-cola
brew install git-extras
brew install git-flow
brew install --zsh-completion git-now
brew install global
brew install gnu-getopt
brew install gnu-sed
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
#brew install jetty
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
brew install oniguruma
brew install openssl
brew install ossp-uuid
brew install pcre
brew install pkg-config
brew install typesafe-activator # play
brew install pngcheck
brew install polipo
brew install postgresql
#brew install postgresql8
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
brew install docker
brew install boot2docker
brew install -v --HEAD xctool
brew install phantomjs
brew install htop
brew install wireshark
#brew install clamav
brew install qemu
brew install jigdo
brew install libvirt
brew install fping
brew install ddrescue
#brew install sshuttle
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

# jsl
brew tap homebrew/binary
brew install jsl

# ricty
brew tap sanemat/font
brew install --powerline --vim-powerline ricty

#brew install the_legacy_searcher


# peco
brew tap peco/peco
brew install peco/peco/peco

# homebrew-cask
brew tap caskroom/cask
brew install caskroom/cask/brew-cask

brew tap caskroom/versions

brew cask install xquartz || true
brew cask install --appdir=/Applications alfred || true
brew cask install --appdir=/Applications appcleaner || true
brew cask install --appdir=/Applications bettertouchtool || true
brew cask install --appdir=/Applications cyberduck || true
brew cask install --appdir=/Applications freemind || true
brew cask install --appdir=/Applications google-chrome || true
brew cask install --appdir=/Applications google-japanese-ime || true
brew cask install --appdir=/Applications grandperspective || true
brew cask install --appdir=/Applications iterm2 || true
brew cask install --appdir=/Applications keyremap4macbook || true
brew cask install --appdir=/Applications kobito || true
brew cask install --appdir=/Applications codekit || true
brew cask install --appdir=/Applications libreoffice || true
brew cask install --appdir=/Applications lightpaper || true
brew cask install --appdir=/Applications mou || true
brew cask install --appdir=/Applications pgadmin3 || true
brew cask install --appdir=/Applications skitch || true
brew cask install --appdir=/Applications sourcetree || true
brew cask install --appdir=/Applications sublime-text || true
brew cask install --appdir=/Applications vagrant || true
brew cask install --appdir=/Applications xmarks-safari || true
brew cask install --appdir=/Applications webstorm || true
brew cask install --appdir=/Applications intellij-idea-ce || true
brew cask install --appdir=/Applications uncrustifyx || true
brew cask install --appdir=/Applications xmind || true
#brew cask install --appdir=/Applications eclipse-jee || true
brew cask install --appdir=/Applications cinch || true
brew cask install --appdir=/Applications dash || true
brew cask install --appdir=/Applications colors || true
brew cask install --appdir=/Applications seashore || true
#brew cask install virtualbox || true
brew cask install oclint || true
#brew cask install java || true # 1.8

#brew cask install --appdir=/Applications android-studio || true
#brew cask install --appdir=/Applications appcode || true
#brew cask install --appdir=/Applications cheatsheet || true
#brew cask install --appdir=/Applications diffmerge || true
brew cask install --appdir=/Applications gimp || true
#brew cask install --appdir=/Applications imageoptim || true
#brew cask install --appdir=/Applications integrity || true
#brew cask install --appdir=/Applications iphoney || true
brew cask install --appdir=/Applications licecap || true
#brew cask install --appdir=/Applications opera || true
brew cask install --appdir=/Applications evernote || true
brew cask install --appdir=/Applications unetbootin || true
brew cask install --appdir=/Applications keepassx || true
brew cask install --appdir=/Applications chicken || true
brew cask install --appdir=/Applications jxplorer || true
brew cask install --appdir=/Applications sdformatter || true
brew cask install --appdir=/Applications clipmenu || true
brew cask install --appdir=/Applications 0xdbe-eap || true

# caskroom/versions
brew cask install --appdir=/Applications macvim-kaoriya || true
brew cask install --appdir=/Applications firefox-ja || true
brew cask install --appdir=/Applications thunderbird-ja || true
brew cask install java6 || true

#brew cask alfred link

#brew cleanup -s
