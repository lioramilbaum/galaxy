#!/bin/sh

sudo apt-get update
sudo apt-get -y install python-software-properties
sudo apt-add-repository -y ppa:brightbox/ruby-ng
sudo apt-get update
sudo apt-get install -y ruby2.2 ruby2.2-dev g++ make autoconf rubygems
sudo gem install berkshelf --no-ri --no-rdoc --verbose

exit 0