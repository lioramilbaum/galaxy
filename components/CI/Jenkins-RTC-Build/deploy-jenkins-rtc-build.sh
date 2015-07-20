#!/bin/sh

. /vagrant/conf/Galaxy.cfg

sudo sed -i "s/ALM_HOSTNAME/localhost/g" /vagrant/components/CI/Jenkins-RTC-Build/com.ibm.team.build.internal.hjplugin.RTCScm.xml
sudo cp /vagrant/components/CI/Jenkins-RTC-Build/com.ibm.team.build.internal.hjplugin.RTC* $JENKINS_HOME
sudo cp /vagrant/components/CI/Jenkins-RTC-Build/credentials.xml $JENKINS_HOME
java -jar $JENKINS_CLI_JAR -s http://localhost:8080/ restart

exit 0