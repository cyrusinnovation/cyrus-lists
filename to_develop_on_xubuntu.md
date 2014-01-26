## make caps lock another CTRL
1. $ sudo apt-get install xkeycaps
1. $ xkeycaps
1. choose keyboard layout
1. right click on left-ctrl
1. choose duplicate key
1. double click on caps lock
1. click "write output"

## install git
1. $ sudo apt-get install git

## build emacs from source (http://thornydev.blogspot.com/2012/06/setting-up-emacs-24-on-ubuntu-to-use.html)
1. $ sudo apt-get install autoconf xorg-dev libjpeg-dev libpng-dev libgif-dev libtiff4-dev libncurses-dev texinfo libxpm-dev
1. $ git clone git://git.savannah.gnu.org/emacs.git
1. $ cd emacs/
1. $ ./autogen.sh && ./configure && make
1. $ src/emacs -Q # verify emacs
1. $ sudo make install

## install rvm
1. set terminal to run as a login shell (http://docs.xfce.org/apps/terminal/preferences)
1. $ sudo apt-get install libtool curl openssl libssl-dev libyaml-dev libreadline-dev
1. $ curl -L https://get.rvm.io | bash -s stable --ruby
1. $ rvm get head --auto
1. $ source ~/.rvm/scripts/rvm

## generate ssh keypair (https://help.github.com/articles/generating-ssh-keys#platform-linux)
1. $ ssh-keygen -t rsa -C "mraibert@cyrusinnovation.com"
1. $ sudo apt-get install xclip
1. $ xclip -sel clip < ~/.ssh/id_rsa.pub 
1. upload key
1. $ git clone git@github.com:cyrusinnovation/ListList.git

## install gems
1. $ sudo apt-get install libxslt-dev libxml2-dev      # for nokogiri
1. $ sudo apt-get install postgresql-server-dev-9.1    # for pg
1. $ sudo apt-get install libsqlite3-dev               # for sqlite3
1. $ sudo apt-get install nodejs                       # for execjs
1. $ bundle install
1. $ rake db:create
1. $ rake db:migrate
1. $ rake
1. $ rails s

## install rubymine
1. $ sudo apt-get install openjdk-6-jdk
1. $ wget http://download.jetbrains.com/ruby/RubyMine-4.5.2.tar.gz
1. $ tar -xvzf RubyMine-4.5.2.tar.gz 
1. $ sudo mv RubyMine-4.5.2 /opt
1. $ cd /usr/bin
1. $ sudo ln -s /opt/RubyMine-4.5.2/bin/rubymine.sh rubymine
1. $ rubymine
