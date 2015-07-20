#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_ARTIFACTORY || exit 0

echo "==> ${projectName}: Artifactory Service Installation"

/vagrant/components/utilities/packageGet.py JFrog/Artifactory/artifactory-powerpack-standalone-3.6.0.zip
sudo mkdir -p /opt/jfrog
sudo unzip /vagrant/artifactory-powerpack-standalone-3.6.0.zip -d /opt/jfrog > /dev/null
if [ $? -ne 0 ]; then
   exit 1;
fi
sudo /opt/jfrog/artifactory-powerpack-3.6.0/bin/installService.sh
if [ $? -ne 0 ]; then
   exit 1;
fi
sudo service artifactory start
sleep 1m
sudo service artifactory check

echo "==> ${projectName}: Setting Artifactory"
curl -s -u admin:password -X POST -H "Content-Type:application/json" -d @/vagrant/components/REPO/Artifactory/license.json           http://localhost:8081/artifactory/api/system/license
curl -s -u admin:password -X POST -H "Content-type:application/xml"  -d @/vagrant/components/REPO/Artifactory/artifactory.config.xml http://localhost:8081/artifactory/api/system/configuration

exit 0

