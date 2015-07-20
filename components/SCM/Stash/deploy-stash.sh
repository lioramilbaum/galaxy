#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_STASH || exit 0

sudo apt-get install -y python-pip curl
sudo pip install --user wget

/vagrant/components/utilities/packageGet.py Atlassian/atlassian-stash-3.6.1-x64.bin

echo "==> Galaxy: Java Installation"
sudo apt-get -y install openjdk-7-jre-headless
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
echo "==> Galaxy: Attlasian Stash Installation"
sudo /vagrant/atlassian-stash-3.6.1-x64.bin -q

#curl -s http://localhost:7990/setup

exit 0