#!/bin/sh

sudo apt-get update
sudo apt-get install -y ruby libxslt-dev libxml2-dev rubygems
gem install berkshelf --no-ri --no-rdoc

exit 0