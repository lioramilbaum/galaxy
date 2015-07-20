#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_BAMBOO || exit 0

BAMBOO_INSTALL_DIR=/opt/atlassian/bamboo
BAMBOO_HOME=/home/bamboo

/vagrant/components/utilities/packageGet.py Atlassian/atlassian-bamboo-5.8.1.tar.gz

sudo mkdir -p $BAMBOO_INSTALL_DIR
tar -zxvf /vagrant/atlassian-bamboo-5.8.1.tar.gz -C $BAMBOO_INSTALL_DIR > /dev/null

sudo /usr/sbin/useradd --create-home --home-dir $BAMBOO_HOME bamboo

sudo apt-get -y install software-properties-common python-software-properties
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk ant
sudo echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.profile

sudo echo "bamboo.home=$BAMBOO_HOME" >> $BAMBOO_INSTALL_DIR/atlassian-bamboo-5.8.1/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties

sudo $BAMBOO_INSTALL_DIR/atlassian-bamboo-5.8.1/bin/start-bamboo.sh

exit 0