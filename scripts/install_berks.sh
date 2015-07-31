#!/bin/sh

sudo apt-get -y install python-software-properties g++
sudo apt-add-repository -y ppa:brightbox/ruby-ng
sudo apt-get update
sudo apt-get install -y ruby2.2 ruby2.2-dev
sudo gem install berkshelf --no-ri --no-rdoc --verbose

exit 0