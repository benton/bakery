#!/usr/bin/env bash
# Installs the requested MRI ruby as the default Ruby on Ubuntu.
# Also updates rubygems and installs the bundler gem.
set -e

# configuration - set $RUBY_SRC_URL to override the DEFAULT_RUBY
DEFAULT_RUBY="ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p327.tar.gz"
if [ "$RUBY_SRC_URL" == "" ] ; then RUBY_SRC_URL="$DEFAULT_RUBY" ; fi
TMP_DIR="/tmp"
TGZ_FILE="$TMP_DIR/$(basename $RUBY_SRC_URL)"
BUILD_DIR="$TMP_DIR/$(basename $RUBY_SRC_URL .tar.gz)"

# system package update
PACKAGES="build-essential openssl libreadline6 libreadline6-dev
curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev
sqlite3 libxml2-dev libxslt1-dev autoconf libc6-dev ncurses-dev automake
libtool bison nodejs subversion wget"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y install $PACKAGES

# download
mkdir -p $BUILD_DIR
wget -O $TGZ_FILE $RUBY_SRC_URL
tar -C $TMP_DIR -xzf $TGZ_FILE

# build and install
cd $BUILD_DIR
./configure
make
sudo make install
cd -
sudo gem update --system
sudo gem install bundler

# clean up
rm -rf $TGZ_FILE $BUILD_DIR
