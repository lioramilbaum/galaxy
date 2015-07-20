#!/bin/sh

. /vagrant/conf/Galaxy.cfg

JENKINS_CLI_JAR=/tmp/jenkins-cli.jar
JENKINS_HOME=/var/lib/jenkins

wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins
sleep 1m
echo ">>>Download Jenkins cli jar"
curl -s http://localhost:8080/jnlpJars/jenkins-cli.jar > $JENKINS_CLI_JAR

echo ">>>Force update the plugin list"
wget -O /tmp/default.js http://updates.jenkins-ci.org/update-center.json
sed '1d;$d' /tmp/default.js > /tmp/default.json
curl -s -X POST -H "Accept: application/json" -d @/tmp/default.json http://localhost:8080/updateCenter/byId/default/postBack

echo ">>>Jenkins Plugin List"
java -jar $JENKINS_CLI_JAR -s http://localhost:8080/ list-plugins

echo ">>>Jenkins Plugins"
java -jar $JENKINS_CLI_JAR -s http://localhost:8080/ install-plugin teamconcert
UPDATE_LIST=$(java -jar $JENKINS_CLI_JAR -s http://localhost:8080/ list-plugins | grep -e ')$' | awk '{ print $1 }' ) 
if [ ! -z "${UPDATE_LIST}" ]
then
    echo ">>>Updating Jenkins Plugins: ${UPDATE_LIST}"
    java -jar $JENKINS_CLI_JAR -s http://localhost:8080/ install-plugin ${UPDATE_LIST} teamconcert
    java -jar $JENKINS_CLI_JAR -s http://localhost:8080/ safe-restart
fi

exit 0