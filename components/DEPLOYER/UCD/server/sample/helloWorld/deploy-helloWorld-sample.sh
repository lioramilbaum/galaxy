#!/bin/sh

. /vagrant/conf/Galaxy.cfg

echo "==> ${projectName}: Add the agent as a resource"
/bin/echo -e "{\n\t"name": "helloWorldTutorial"\n}" > /tmp/resource.json
curl -s -X PUT -u admin:admin  -d @/tmp/resource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

/bin/echo -e "{\n\t"agent": "$UCD_HOSTNAME",\n\t"parent": \"\/helloWorldTutorial\"\n}" > /tmp/agentresource.json
curl -s -X PUT -u admin:admin  -d @/tmp/agentresource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure

mkdir /tmp/helloWorld
mkdir /tmp/helloWorld/1.0
echo "hello" > /tmp/helloWorld/1.0/main.txt
mkdir /tmp/helloWorld/2.0
echo "Hello World" > /tmp/helloWorld/2.0/main.txt

echo "==> ${projectName}: Create a Component"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/server/sample/helloWorld/comp.json https://$UCD_HOSTNAME:8443/cli/component/create --insecure
echo "==> ${projectName}: Create a component property"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/component/propValue?name=helloHome&value=/tmp/helloWorld&component=helloWorld" --insecure
echo "==> ${projectName}: Import Component Versions"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/server/sample/helloWorld/compVersion.json https://$UCD_HOSTNAME:8443/cli/component/integrate --insecure
echo "==> ${projectName}: Create Component Process"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/server/sample/helloWorld/compProcess.json https://$UCD_HOSTNAME:8443/cli/componentProcess/create --insecure
echo "==> ${projectName}: Create Application"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/server/sample/helloWorld/app.json https://$UCD_HOSTNAME:8443/cli/application/create --insecure
echo "==> ${projectName}: Add component to the application"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/application/addComponentToApp?component=helloWorld&application=helloApplication" --insecure
echo "==> ${projectName}: Create Application Environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/createEnvironment?application=helloApplication&name=helloDeploy&color=#D9182D" --insecure
echo "==> ${projectName}: Add the resource group to the environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/addBaseResource?application=helloApplication&environment=helloDeploy&resource=/helloWorldTutorial" --insecure
echo "==> ${projectName}: Map the component to this agent resource"
sudo cp /vagrant/components/DEPLOYER/UCD/compResource.json /tmp
sudo sed -i "s/COMP_NAME/helloWorld/g" /tmp/compResource.json
sudo sed -i "s/AGENT_HOSTNAME/$UCD_HOSTNAME/g" /tmp/compResource.json
sudo sed -i "s/PARENT_RESOURCE/helloWorldTutorial/g" /tmp/compResource.json
curl -s -X PUT -u admin:admin  -d @/tmp/compResource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure
echo "==> ${projectName}: Add a tag to the component resource"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/resource/tag?resource=/helloWorldTutorial/$UCD_HOSTNAME/helloWorld&tag=blueCycle&color=003EFF" --insecure
echo "==> ${projectName}: Create an application process"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/server/sample/helloWorld/applicationProcess.json https://$UCD_HOSTNAME:8443/cli/applicationProcess/create --insecure
/bin/echo -e "\n==> ${projectName}: Run an application process"
sleep 1m
result=`curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/server/sample/helloWorld/runApplicationProcess.json https://$UCD_HOSTNAME:8443/cli/applicationProcessRequest/request --insecure`
REQUEST_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["requestId"];'`
sleep 1m
echo "==> ${projectName}: Request the status of an application process request"
curl -s -X GET -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/applicationProcessRequest/requestStatus?request=$REQUEST_ID" --insecure

exit 0