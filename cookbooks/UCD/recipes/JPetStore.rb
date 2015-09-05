include_recipe "libarchive::default"

bash 'mysql' do
	code <<-EOH
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
	EOH
	notifies :install, 'package[mysql-server]', :immediately
end

package 'mysql-server' do
	action :nothing
	notifies :run, 'bash[jpetstore-mysql]', :immediately
end

bash 'jpetstore-mysql' do
	code <<-EOH
mysql -uroot -proot -e "create database jpetstore;"
mysql -uroot -proot -e "create user 'jpetstore'@'localhost' identified by 'jppwd';"
mysql -uroot -proot -e "grant all privileges on jpetstore.* to 'jpetstore'@'localhost';"
	EOH
	action :nothing
end

package ['tomcat7', 'tomcat7-admin'] do
	action :install
	notifies :create, 'cookbook_file[tomcat-users.xml]', :immediately
end

cookbook_file "tomcat-users.xml" do
	path "/var/lib/tomcat7/conf/tomcat-users.xml"
	action :nothing	
	notifies :restart, 'service[tomcat7]', :immediately
end

service 'tomcat7' do
	action :nothing
end

remote_file "/tmp/artifacts.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/samples/artifacts.zip"
	action :create
	notifies :extract, 'libarchive_file[Extracting artifacts zip]', :immediately
end

libarchive_file "Extracting artifacts zip" do
  path "/tmp/artifacts.zip"
  extract_to "/tmp/artifacts"
  action :nothing
end

bash 'petStore' do
	code <<-EOH
result=`curl -s -X GET -u admin:admin https://#{node['ec2']['public_hostname']}:8443/cli/agentCLI/info?agent=#{node['ec2']['public_hostname']} --insecure`
AGENT_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`

AGENT_RESOURCE="Server Agent"

sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersionConfig.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-APP/g" /tmp/compVersionConfig.json
sudo sed -i "s/AGENT_ID/$AGENT_ID/g" /tmp/compVersionConfig.json
sudo sed -i "s/COMP_BASE/app/g" /tmp/compVersionConfig.json
result=`curl -s -X PUT -b #{node['UCD']['cookies']} -c #{node['UCD']['cookies']} -u admin:admin -d @/tmp/compVersionConfig.json https://#{node['ec2']['public_hostname']}:8443/rest/deploy/component --insecure`
COMP_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`

sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersion.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-APP/g" /tmp/compVersion.json
result=`curl -s -X PUT -u admin:admin  -d @/tmp/compVersion.json https://#{node['ec2']['public_hostname']}:8443/cli/component/integrate --insecure`

sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersionConfig.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-DB/g" /tmp/compVersionConfig.json
sudo sed -i "s/AGENT_ID/$AGENT_ID/g" /tmp/compVersionConfig.json
sudo sed -i "s/COMP_BASE/db/g" /tmp/compVersionConfig.json

result=`curl -s -X PUT -b #{node['UCD']['cookies']} -c #{node['UCD']['cookies']} -u admin:admin -d @/tmp/compVersionConfig.json https://#{node['ec2']['public_hostname']}:8443/rest/deploy/component --insecure`
COMP_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`

sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersion.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-DB/g" /tmp/compVersion.json

result=`curl -s -X PUT -u admin:admin  -d @/tmp/compVersion.json https://#{node['ec2']['public_hostname']}:8443/cli/component/integrate --insecure`

sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersionConfig.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-WEB/g" /tmp/compVersionConfig.json
sudo sed -i "s/AGENT_ID/$AGENT_ID/g" /tmp/compVersionConfig.json
sudo sed -i "s/COMP_BASE/web/g" /tmp/compVersionConfig.json

result=`curl -s -X PUT -b #{node['UCD']['cookies']} -c #{node['UCD']['cookies']} -u admin:admin -d @/tmp/compVersionConfig.json https://#{node['ec2']['public_hostname']}:8443/rest/deploy/component --insecure`
COMP_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"];'`

sudo cp /vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/compVersion.json /tmp
sudo sed -i "s/COMP_NAME/JPetStore-WEB/g" /tmp/compVersion.json

result=`curl -s -X PUT -u admin:admin  -d @/tmp/compVersion.json https://#{node['ec2']['public_hostname']}:8443/cli/component/integrate --insecure`
curl -s -X PUT -u admin:admin -d @/vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/JPetStore-APP-Process.json https://#{node['ec2']['public_hostname']}:8443/cli/componentProcess/create --insecure
curl -s -X PUT -u admin:admin -d @/vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/JPetStore-DB-Process.json  https://#{node['ec2']['public_hostname']}:8443/cli/componentProcess/create --insecure
curl -s -X PUT -u admin:admin -d @/vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/JPetStore-WEB-Process.json https://#{node['ec2']['public_hostname']}:8443/cli/componentProcess/create --insecure
	EOH
end

template "/tmp/app.json" do
	source "app.json.erb"  	
	variables ({
		:app_name => "JPetStore"
	})
	action :create
end

bash 'petStore1' do
	code <<-EOH
	
AGENT_RESOURCE="Server+Agent"

curl -s -X PUT -u admin:admin  -d @/tmp/app.json https://#{node['ec2']['public_hostname']}:8443/cli/application/create --insecure

curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/application/addComponentToApp?component=JPetStore-APP&application=JPetStore" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/application/addComponentToApp?component=JPetStore-DB&application=JPetStore" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/application/addComponentToApp?component=JPetStore-WEB&application=JPetStore" --insecure

curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=PROD-TX&color=#00B2EF" --insecure

curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=tomcat.home&value=/var/lib/tomcat7" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=db.url&value=jdbc:mysql://localhost:3306/jpetstore" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=tomcat.manager.url&value=http://localhost:8080/manager/text" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=tomcat.start&value=/usr/share/tomcat7/bin/startup.sh" --insecure

curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/addBaseResource?application=JPetStore&environment=DEV-1&resource=/$AGENT_RESOURCE" --insecure
	EOH
end

template "/tmp/compResource.json" do
	source "compResource.json.erb"
  	variables (
		lazy {
			{
				:comp_name => "JPetStore-APP",
				:agent_hostname => node['ec2']['public_hostname'],
				:parent_resource => "Server Agent"
			}
		}
	)
	action :create
end

bash 'compResource JPetStore-APP' do
  code <<-EOH
curl -s -X PUT -u admin:admin  -d @/tmp/compResource.json https://#{node['ec2']['public_hostname']}:8443/cli/resource/create --insecure
  EOH
end

template "/tmp/compResource.json" do
	source "compResource.json.erb"
  	variables (
		lazy {
			{
				:comp_name => "JPetStore-DB",
				:agent_hostname => node['ec2']['public_hostname'],
				:parent_resource => "Server Agent"
			}
		}
	)
	action :create
end

bash 'compResource JPetStore-DB' do
  code <<-EOH
curl -s -X PUT -u admin:admin  -d @/tmp/compResource.json https://#{node['ec2']['public_hostname']}:8443/cli/resource/create --insecure
  EOH
end

template "/tmp/compResource.json" do
	source "compResource.json.erb"
  	variables (
		lazy {
			{
				:comp_name => "JPetStore-WEB",
				:agent_hostname => node['ec2']['public_hostname'],
				:parent_resource => "Server Agent"
			}
		}
	)
	action :create
end

bash 'compResource JPetStore-WEB' do
  code <<-EOH
curl -s -X PUT -u admin:admin  -d @/tmp/compResource.json https://#{node['ec2']['public_hostname']}:8443/cli/resource/create --insecure

curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/applicationProcess.json https://#{node['ec2']['public_hostname']}:8443/cli/applicationProcess/create --insecure

sleep 1m
result=`curl -s -X PUT -u admin:admin  -d @/vagrant/components/DEPLOYER/UCD/agent1/sample/JPetStore/runApplicationProcess.json https://#{node['ec2']['public_hostname']}:8443/cli/applicationProcessRequest/request --insecure`
REQUEST_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["requestId"];'`
sleep 2m
curl -s -X GET -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/applicationProcessRequest/requestStatus?request=$REQUEST_ID" --insecure
  EOH
end

template "/tmp/app.json" do
	source "app.json.erb"  	
	variables ({
		:app_name => "Pet Grooming Reservations"
	})
	action :create
end

bash 'deploy' do
  code <<-EOH
curl -s -X PUT -u admin:admin https://#{node['ec2']['public_hostname']}:8443/cli/application/create -d @/tmp/app.json --insecure
APP="Pet%20Grooming%20Reservations"
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure
  EOH
end

template "/tmp/app.json" do
	source "app.json.erb"  	
	variables ({
		:app_name => "Pet Transport"
	})
	action :create
end

bash 'deploy' do
  code <<-EOH
curl -s -X PUT -u admin:admin https://#{node['ec2']['public_hostname']}:8443/cli/application/create -d @/tmp/app.json --insecure
APP="Pet+Transport"	
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure
  EOH
end
	
template "/tmp/app.json" do
	source "app.json.erb"  	
	variables ({
		:app_name => "Pet Breeder Site"
	})
	action :create
end

bash 'deploy' do
  code <<-EOH
curl -s -X PUT -u admin:admin https://#{node['ec2']['public_hostname']}:8443/cli/application/create -d @/tmp/app.json --insecure
APP="Pet+Breeder+Site"	
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure
  EOH
end

template "/tmp/app.json" do
	source "app.json.erb"  	
	variables ({
		:app_name => "Pet Sourcing"
	})
	action :create
end

bash 'deploy' do
  code <<-EOH	
curl -s -X PUT -u admin:admin https://#{node['ec2']['public_hostname']}:8443/cli/application/create -d @/tmp/app.json --insecure
APP="Pet+Sourcing"	
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure
  EOH
end