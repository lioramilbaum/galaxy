#!/bin/bash

. /vagrant/conf/Galaxy.cfg

COOKIES=/tmp/cookies.txt

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server
mysql -uroot -proot -e "create database jpetstore;"
mysql -uroot -proot -e "create user 'jpetstore'@'localhost' identified by 'jppwd';"
mysql -uroot -proot -e "grant all privileges on jpetstore.* to 'jpetstore'@'localhost';"

sudo apt-get install -y tomcat7 tomcat7-admin
sudo cp -f /vagrant/components/DEPLOYER/UCD/tomcat-users.xml /var/lib/tomcat7/conf
sudo service tomcat7 restart

unzip /tmp/artifacts.zip -d /tmp/artifacts > /dev/null

result=`curl -s -X GET -u admin:admin https://$UCD_HOSTNAME:8443/cli/agentCLI/info?agent=$AGENT1_HOSTNAME --insecure`
AGENT_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`
echo $AGENT_ID

AGENT_RESOURCE="Agent1 Agent"

echo "==> ${projectName}: Add the agent as a resource"
/bin/echo -e "{\n\t"name": "$AGENT_RESOURCE"\n}" > /tmp/resource.json
curl -s -X PUT -u admin:admin  -d @/tmp/resource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

/bin/echo -e "{\n\t"agent": "$AGENT1_HOSTNAME",\n\t"parent": \"\/$AGENT_RESOURCE\"\n}" > /tmp/agentresource.json
curl -s -X PUT -u admin:admin  -d @/tmp/agentresource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

echo "==> ${projectName}: Create APP Component"

echo "==> ${projectName}: Import new component versions using a single agent"
sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersionConfig.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-APP/g" /tmp/compVersionConfig.json
sudo sed -i "s/AGENT_ID/$AGENT_ID/g" /tmp/compVersionConfig.json
sudo sed -i "s/COMP_BASE/app/g" /tmp/compVersionConfig.json
result=`curl -s -X PUT -b $COOKIES -c $COOKIES -u admin:admin -d @/tmp/compVersionConfig.json https://$UCD_HOSTNAME:8443/rest/deploy/component --insecure`
COMP_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`
echo $COMP_ID

echo "==> ${projectName}: Import Component Versions"
sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersion.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-APP/g" /tmp/compVersion.json
result=`curl -s -X PUT -u admin:admin  -d @/tmp/compVersion.json https://$UCD_HOSTNAME:8443/cli/component/integrate --insecure`
echo $result

echo "==> ${projectName}: Create DB Component"

echo "==> ${projectName}: Import new component versions using a single agent"
sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersionConfig.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-DB/g" /tmp/compVersionConfig.json
sudo sed -i "s/AGENT_ID/$AGENT_ID/g" /tmp/compVersionConfig.json
sudo sed -i "s/COMP_BASE/db/g" /tmp/compVersionConfig.json

result=`curl -s -X PUT -b $COOKIES -c $COOKIES -u admin:admin -d @/tmp/compVersionConfig.json https://$UCD_HOSTNAME:8443/rest/deploy/component --insecure`
COMP_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`
echo $COMP_ID

echo "==> ${projectName}: Import Component Versions"
sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersion.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-DB/g" /tmp/compVersion.json

result=`curl -s -X PUT -u admin:admin  -d @/tmp/compVersion.json https://$UCD_HOSTNAME:8443/cli/component/integrate --insecure`
echo $result

echo "==> ${projectName}: Create WEB Component"

echo "==> ${projectName}: Import new component versions using a single agent"
sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersionConfig.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-WEB/g" /tmp/compVersionConfig.json
sudo sed -i "s/AGENT_ID/$AGENT_ID/g" /tmp/compVersionConfig.json
sudo sed -i "s/COMP_BASE/web/g" /tmp/compVersionConfig.json

result=`curl -s -X PUT -b $COOKIES -c $COOKIES -u admin:admin -d @/tmp/compVersionConfig.json https://$UCD_HOSTNAME:8443/rest/deploy/component --insecure`
COMP_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`
echo $COMP_ID

echo "==> ${projectName}: Import Component Versions"
sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersion.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-WEB/g" /tmp/compVersion.json

result=`curl -s -X PUT -u admin:admin  -d @/tmp/compVersion.json https://$UCD_HOSTNAME:8443/cli/component/integrate --insecure`
echo $result

echo "==> ${projectName}: Create Component Processes"
curl -s -X PUT -u admin:admin -d @/vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/JPetStore-APP-Process.json https://$UCD_HOSTNAME:8443/cli/componentProcess/create --insecure
curl -s -X PUT -u admin:admin -d @/vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/JPetStore-DB-Process.json  https://$UCD_HOSTNAME:8443/cli/componentProcess/create --insecure
curl -s -X PUT -u admin:admin -d @/vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/JPetStore-WEB-Process.json https://$UCD_HOSTNAME:8443/cli/componentProcess/create --insecure

echo "==> ${projectName}: Create Application"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/JPetStore_app.json https://$UCD_HOSTNAME:8443/cli/application/create --insecure

echo "==> ${projectName}: Add components to the application"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/application/addComponentToApp?component=JPetStore-APP&application=JPetStore" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/application/addComponentToApp?component=JPetStore-DB&application=JPetStore" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/application/addComponentToApp?component=JPetStore-WEB&application=JPetStore" --insecure

echo "==> ${projectName}: Create Application Environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/createEnvironment?application=JPetStore&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/createEnvironment?application=JPetStore&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/createEnvironment?application=JPetStore&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/createEnvironment?application=JPetStore&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/createEnvironment?application=JPetStore&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/createEnvironment?application=JPetStore&name=PROD-TX&color=#00B2EF" --insecure

echo "==> ${projectName}: Specify the properties for the environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=tomcat.home&value=/var/lib/tomcat7" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=db.url&value=jdbc:mysql://localhost:3306/jpetstore" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=tomcat.manager.url&value=http://localhost:8080/manager/text" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=tomcat.start&value=/usr/share/tomcat7/bin/startup.sh" --insecure

echo "==> ${projectName}: Add the resource group to the environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/addBaseResource?application=JPetStore&environment=DEV-1&resource=/Agent1+Agent" --insecure

echo "==> ${projectName}: Map the component to this agent resource"
sudo cp /vagrant/components/DEPLOYER/UCD/compResource.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-APP/g" /tmp/compResource.json
sudo sed -i "s/AGENT_HOSTNAME/$AGENT1_HOSTNAME/g" /tmp/compResource.json
sudo sed -i "s/PARENT_RESOURCE/$AGENT_RESOURCE/g" /tmp/compResource.json
curl -s -X PUT -u admin:admin  -d @/tmp/compResource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

sudo cp /vagrant/components/DEPLOYER/UCD/compResource.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-DB/g" /tmp/compResource.json
sudo sed -i "s/AGENT_HOSTNAME/$AGENT1_HOSTNAME/g" /tmp/compResource.json
sudo sed -i "s/PARENT_RESOURCE/$AGENT_RESOURCE/g" /tmp/compResource.json
curl -s -X PUT -u admin:admin  -d @/tmp/compResource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

sudo cp /vagrant/components/DEPLOYER/UCD/compResource.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-WEB/g" /tmp/compResource.json
sudo sed -i "s/AGENT_HOSTNAME/$AGENT1_HOSTNAME/g" /tmp/compResource.json
sudo sed -i "s/PARENT_RESOURCE/$AGENT_RESOURCE/g" /tmp/compResource.json
curl -s -X PUT -u admin:admin  -d @/tmp/compResource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

echo "==> ${projectName}: Create an application process"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/applicationProcess.json https://$UCD_HOSTNAME:8443/cli/applicationProcess/create --insecure

echo -e "\n==> ${projectName}: Run an application process"
sleep 1m
result=`curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/runApplicationProcess.json https://$UCD_HOSTNAME:8443/cli/applicationProcessRequest/request --insecure`
REQUEST_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["requestId"];'`
sleep 2m
echo "==> ${projectName}: Request the status of an application process request"
curl -s -X GET -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/applicationProcessRequest/requestStatus?request=$REQUEST_ID" --insecure

exit 0
