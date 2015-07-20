#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_MAVEN || exit 0

/vagrant/components/utilities/packageGet.py Apache/apache-maven-3.3.1-bin.tar.gz
mkdir /usr/local/apache-maven
tar -zxvf /vagrant/apache-maven-3.3.1-bin.tar.gz -C /usr/local/apache-maven > /dev/null

exit 0