#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_UCR || exit 0

sudo sed -i "s/127.0.1.1/0.0.0.0/g" /opt/IBM/UCRelease/server/tomcat/conf/server.xml

cd /opt/IBM/UCRelease/server
sudo ./server.startup

exit 0