#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_ARTIFACTORY || exit 0

curl -s -u admin:password -X PUT -H "Content-Type: application/json" http://$CI_HOSTNAME:8081/artifactory/api/repositories/lmb-repo?pos=1 -d @/vagrant/components/REPO/Artifactory/sample/JPetStore/repository-config.json

/vagrant/components/utilities/packageGet.py samples/artifacts.zip

curl -s -u admin:password -X PUT -H "X-Explode-Archive: true" http://$CI_HOSTNAME:8081/artifactory/lmb-repo/artifacts.zip -T /vagrant/artifacts.zip

exit 0

