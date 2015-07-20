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

sampleName=Artifactory-JPetStore

/vagrant/components/utilities/packageGet.py samples/artifacts.zip
unzip /vagrant/artifacts.zip -d /tmp/artifacts > /dev/null

AGENT_RESOURCE="AGENT2 Agent"

echo "==> ${projectName}: Add the agent as a resource"
/bin/echo -e "{\n\t"name": "$AGENT_RESOURCE"\n}" > /tmp/resource.json
curl -s -X PUT -u admin:admin  -d @/tmp/resource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

/bin/echo -e "{\n\t"agent": "$AGENT2_HOSTNAME",\n\t"parent": \"\/$AGENT_RESOURCE\"\n}" > /tmp/agentresource.json
curl -s -X PUT -u admin:admin  -d @/tmp/agentresource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

echo "==> ${projectName} ${sampleName}: Set AGENT2 agent as parent resource"
result=`curl -s -X GET -u admin:admin https://$UCD_HOSTNAME:8443/cli/agentCLI/info?agent=$AGENT2_HOSTNAME --insecure`
AGENT_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`
echo $AGENT_ID

echo "==> ${projectName} ${sampleName}: Create APP Component"

echo "==> ${projectName}${sampleName}: Import new component versions using a single agent"
sudo cp /vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/compVersionConfig.json /tmp
sudo sed -i "s/COMP_NAME/Artifactory-JPetStore-APP/g" /tmp/compVersionConfig.json
sudo sed -i "s/AGENT_ID/$AGENT_ID/g" /tmp/compVersionConfig.json
sudo sed -i "s/COMP_BASE/app/g" /tmp/compVersionConfig.json
sudo sed -i "s/EXTENSION/war/g" /tmp/compVersionConfig.json
result=`curl -s -X PUT -b $COOKIES -c $COOKIES -u admin:admin -d @/tmp/compVersionConfig.json https://$UCD_HOSTNAME:8443/rest/deploy/component --insecure`
COMP_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`
echo $COMP_ID

echo "==> ${projectName} ${sampleName}: Import Component Versions"
sudo cp /vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/compVersion.json /tmp
sudo sed -i "s/COMP_NAME/Artifactory-JPetStore-APP/g" /tmp/compVersion.json
result=`curl -s -X PUT -u admin:admin  -d @/tmp/compVersion.json https://$UCD_HOSTNAME:8443/cli/component/integrate --insecure`
echo $result

echo "==> ${projectName} ${sampleName}: Create DB Component"

echo "==> ${projectName} ${sampleName}: Import new component versions using a single agent"
sudo cp /vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/compVersionConfig.json /tmp
sudo sed -i "s/COMP_NAME/Artifactory-JPetStore-DB/g" /tmp/compVersionConfig.json
sudo sed -i "s/AGENT_ID/$AGENT_ID/g" /tmp/compVersionConfig.json
sudo sed -i "s/COMP_BASE/db/g" /tmp/compVersionConfig.json
sudo sed -i "s/EXTENSION/xml/g" /tmp/compVersionConfig.json
result=`curl -s -X PUT -b $COOKIES -c $COOKIES -u admin:admin -d @/tmp/compVersionConfig.json https://$UCD_HOSTNAME:8443/rest/deploy/component --insecure`
COMP_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`
echo $COMP_ID

echo "==> ${projectName} ${sampleName}: Import Component Versions"
sudo cp /vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/compVersion.json /tmp
sudo sed -i "s/COMP_NAME/Artifactory-JPetStore-DB/g" /tmp/compVersion.json
result=`curl -s -X PUT -u admin:admin  -d @/tmp/compVersion.json https://$UCD_HOSTNAME:8443/cli/component/integrate --insecure`
echo $result

echo "==> ${projectName} ${sampleName}: Create WEB Component"

echo "==> ${projectName} ${sampleName}: Import new component versions using a single agent"
sudo cp /vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/compVersionConfig.json /tmp
sudo sed -i "s/COMP_NAME/Artifactory-JPetStore-WEB/g" /tmp/compVersionConfig.json
sudo sed -i "s/AGENT_ID/$AGENT_ID/g" /tmp/compVersionConfig.json
sudo sed -i "s/COMP_BASE/web/g" /tmp/compVersionConfig.json
sudo sed -i "s/EXTENSION/*/g" /tmp/compVersionConfig.json
result=`curl -s -X PUT -b $COOKIES -c $COOKIES -u admin:admin -d @/tmp/compVersionConfig.json https://$UCD_HOSTNAME:8443/rest/deploy/component --insecure`
COMP_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`
echo $COMP_ID

echo "==> ${projectName} ${sampleName}: Import Component Versions"
sudo cp /vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/compVersion.json /tmp
sudo sed -i "s/COMP_NAME/Artifactory-JPetStore-WEB/g" /tmp/compVersion.json
result=`curl -s -X PUT -u admin:admin  -d @/tmp/compVersion.json https://$UCD_HOSTNAME:8443/cli/component/integrate --insecure`
echo $result

echo "==> ${projectName} ${sampleName}: Create Component Processes"
curl -s -X PUT -u admin:admin -d @/vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/Artifactory-JPetStore-APP-Process.json https://$UCD_HOSTNAME:8443/cli/componentProcess/create --insecure
curl -s -X PUT -u admin:admin -d @/vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/Artifactory-JPetStore-DB-Process.json https://$UCD_HOSTNAME:8443/cli/componentProcess/create --insecure
curl -s -X PUT -u admin:admin -d @/vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/Artifactory-JPetStore-WEB-Process.json https://$UCD_HOSTNAME:8443/cli/componentProcess/create --insecure
curl -s -X PUT -u admin:admin -d @/vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/JPetStore-DB-Import-Process.json https://$UCD_HOSTNAME:8443/cli/componentProcess/create --insecure
curl -s -X PUT -u admin:admin -d @/vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/JPetStore-WEB-Import-Process.json https://$UCD_HOSTNAME:8443/cli/componentProcess/create --insecure

echo "==> ${projectName} ${sampleName}: Create Artifactory-JPetStore Application"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/JPetStore_app.json https://$UCD_HOSTNAME:8443/cli/application/create --insecure

echo "==> ${projectName} ${sampleName}: Create Artifactory-JPetStore-Upload Application"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/Artifactory-JPetStore-Upload_app.json https://$UCD_HOSTNAME:8443/cli/application/create --insecure

echo "==> ${projectName} ${sampleName}: Add components to Artifactory-JPetStore application"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/application/addComponentToApp?component=Artifactory-JPetStore-APP&application=Artifactory-JPetStore" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/application/addComponentToApp?component=Artifactory-JPetStore-DB&application=Artifactory-JPetStore" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/application/addComponentToApp?component=Artifactory-JPetStore-WEB&application=Artifactory-JPetStore" --insecure

echo "==> ${projectName} ${sampleName}: Add components to Artifactory-JPetStore-Upload application"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/application/addComponentToApp?component=Artifactory-JPetStore-DB&application=Artifactory-JPetStore-Upload" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/application/addComponentToApp?component=Artifactory-JPetStore-WEB&application=Artifactory-JPetStore-Upload" --insecure

echo "==> ${projectName} ${sampleName}: Create Artifactory-JPetStore Application Environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/createEnvironment?application=Artifactory-JPetStore&name=DEV" --insecure

echo "==> ${projectName} ${sampleName}: Create Artifactory-JPetStore-Upload Application Environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/createEnvironment?application=Artifactory-JPetStore-Upload&name=DEV" --insecure

echo "==> ${projectName} ${sampleName}: Specify the properties for the environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/propValue?application=Artifactory-JPetStore&environment=DEV&name=tomcat.home&value=/var/lib/tomcat7" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/propValue?application=Artifactory-JPetStore&environment=DEV&name=db.url&value=jdbc:mysql://localhost:3306/jpetstore" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/propValue?application=Artifactory-JPetStore&environment=DEV&name=tomcat.manager.url&value=http://localhost:8080/manager/text" --insecure
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/propValue?application=Artifactory-JPetStore&environment=DEV&name=tomcat.start&value=/usr/share/tomcat7/bin/startup.sh" --insecure

echo "==> ${projectName} ${sampleName}: Add the resource group to the Artifactory-JPetStore environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/addBaseResource?application=Artifactory-JPetStore&environment=DEV&resource=/AGENT2+Agent" --insecure

echo "==> ${projectName} ${sampleName}: Add the resource group to the Artifactory-JPetStore-Upload environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/addBaseResource?application=Artifactory-JPetStore-Upload&environment=DEV&resource=/AGENT2+Agent" --insecure

echo "==> ${projectName} ${sampleName}: Map the component to Artifactory-JPetStore agent resource"
sudo cp /vagrant/components/DEPLOYER/UCD/compResource.json /tmp
sudo sed -i "s/COMP_NAME/Artifactory-JPetStore-APP/g" /tmp/compResource.json
sudo sed -i "s/AGENT_HOSTNAME/$AGENT2_HOSTNAME/g" /tmp/compResource.json
sudo sed -i "s/PARENT_RESOURCE/$AGENT_RESOURCE/g" /tmp/compResource.json
curl -s -X PUT -u admin:admin  -d @/tmp/compResource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

sudo cp /vagrant/components/DEPLOYER/UCD/compResource.json /tmp
sudo sed -i "s/COMP_NAME/Artifactory-JPetStore-DB/g" /tmp/compResource.json
sudo sed -i "s/AGENT_HOSTNAME/$AGENT2_HOSTNAME/g" /tmp/compResource.json
sudo sed -i "s/PARENT_RESOURCE/$AGENT_RESOURCE/g" /tmp/compResource.json
curl -s -X PUT -u admin:admin  -d @/tmp/compResource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

sudo cp /vagrant/components/DEPLOYER/UCD/compResource.json /tmp
sudo sed -i "s/COMP_NAME/Artifactory-JPetStore-WEB/g" /tmp/compResource.json
sudo sed -i "s/AGENT_HOSTNAME/$AGENT2_HOSTNAME/g" /tmp/compResource.json
sudo sed -i "s/PARENT_RESOURCE/$AGENT_RESOURCE/g" /tmp/compResource.json
curl -s -X PUT -u admin:admin  -d @/tmp/compResource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

echo "==> ${projectName} ${sampleName}: Create an application process"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/applicationProcess.json https://$UCD_HOSTNAME:8443/cli/applicationProcess/create --insecure

echo "==> ${projectName} ${sampleName}: Create an application process"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/UploadAppProcess.json https://$UCD_HOSTNAME:8443/cli/applicationProcess/create --insecure

echo -e "\n==> ${projectName} ${sampleName}: Run an application process"
sleep 1m
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/runUploadAppProcess.json https://$UCD_HOSTNAME:8443/cli/applicationProcessRequest/request --insecure
sleep 1m
result=`curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/agent2/sample/Artifactory-JPetStore/runApplicationProcess.json https://$UCD_HOSTNAME:8443/cli/applicationProcessRequest/request --insecure`
REQUEST_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["requestId"];'`
sleep 3m
echo "==> ${projectName} ${sampleName}: Request the status of an application process request"
curl -s -X GET -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/applicationProcessRequest/requestStatus?request=$REQUEST_ID" --insecure

exit 0