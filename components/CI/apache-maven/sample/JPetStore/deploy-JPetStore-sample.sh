#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_MAVEN || exit 0

/usr/local/apache-maven/apache-maven-3.3.1/bin/mvn archetype:generate -DgroupId=com.lmb.app -DartifactId=JPetStore -Dversion=1.0 -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
sudo cp /vagrant/components/CI/apache-maven/sample/JPetStore/pom.xml JPetStore
/usr/local/apache-maven/apache-maven-3.3.1/bin/mvn war:war -f JPetStore/pom.xml

exit 0

