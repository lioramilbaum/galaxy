template "#{Chef::Config['file_cache_path']}/app.json" do
	source "app.json.erb"  	
	variables ({
		:app_name => "AWS"
	})
	action :create
end

bash 'create Resources' do
	code <<-EOH
UCD_HOSTNAME=$1

echo "==> ${projectName}: Create a Component"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/server/sample/AWS/comp.json https://$UCD_HOSTNAME:8443/cli/component/create --insecure
echo "==> ${projectName}: Create Component Process"
curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/server/sample/AWS/compProcess.json https://$UCD_HOSTNAME:8443/cli/componentProcess/create --insecure
echo "==> ${projectName}: Create Application"
curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/app.json https://$UCD_HOSTNAME:8443/cli/application/create --insecure
echo "==> ${projectName}: Add component to the application"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/application/addComponentToApp?component=EC2-Ubuntu-AMI&application=AWS" --insecure
echo "==> ${projectName}: Create Application Environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/createEnvironment?application=AWS&name=DEV&color=#D9182D" --insecure

echo "==> ${projectName}: Add the agent as a resource"
/bin/echo -e "{\n\t"name": "EC2"\n}" > #{Chef::Config['file_cache_path']}/resource.json
curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/resource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure
/bin/echo -e "{\n\t"agent": "$UCD_HOSTNAME",\n\t"parent": \"\/EC2\"\n}" > #{Chef::Config['file_cache_path']}/agentresource.json
curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/agentresource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure
echo "==> ${projectName}: Map the component to this agent resource"
sudo cp /vagrant/components/DEPLOYER/UCD/compResource.json #{Chef::Config['file_cache_path']}
sudo sed -i "s/COMP_NAME/EC2_Ubuntu-AMI/g" #{Chef::Config['file_cache_path']}/compResource.json
sudo sed -i "s/AGENT_HOSTNAME/$UCD_HOSTNAME/g" #{Chef::Config['file_cache_path']}/compResource.json
sudo sed -i "s/PARENT_RESOURCE/EC2/g" #{Chef::Config['file_cache_path']}/compResource.json
curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/compResource.json https://$UCD_HOSTNAME:8443/cli/resource/create --insecure


echo "==> ${projectName}: Add the resource group to the environment"
curl -s -X PUT -u admin:admin  "https://$UCD_HOSTNAME:8443/cli/environment/addBaseResource?application=AWS&environment=DEV&resource=/EC2" --insecure
	EOH
end