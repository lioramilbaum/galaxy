#!/bin/sh

sudo apt-get update
sudo apt-get install -y rubygems
gem install berkshelf --no-ri --no-rdoc

exit 0