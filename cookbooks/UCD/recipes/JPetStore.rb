include_recipe "libarchive::default"

ucd_servers = search(:node, 'role:ucd_server')

if ( ucd_servers.empty? or node[:roles].include?('ucd_server') )
	node.default['UCD']['server_hostname']		= node['ec2']['public_hostname']
	node.default['UCD']['server_private_ips']	= '127.0.0.1'
else
    node.default['UCD']['server_hostname']		= ucd_servers[0].cloud.public_hostname
    node.default['UCD']['server_private_ips']	= ucd_servers[0].cloud.private_ips[0]
end

remote_file "#{Chef::Config['file_cache_path']}/artifacts.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/samples/artifacts.zip"
	action :create
	notifies :extract, 'libarchive_file[Extracting artifacts zip]', :immediately
end

libarchive_file "Extracting artifacts zip" do
  path "#{Chef::Config['file_cache_path']}/artifacts.zip"
  extract_to "#{Chef::Config['file_cache_path']}/artifacts"
  action :nothing
end

template "#{Chef::Config['file_cache_path']}/topLevelResource.json" do
	source "topLevelResource.json.erb" 
	variables ({
		:topLevel_group => "JPetStore Agents"
	})
	action :create
end

template "#{Chef::Config['file_cache_path']}/agentResource.json" do
	source "agentResource.json.erb" 
  	variables (
		lazy {
			{
				:agent_hostname => node['ec2']['public_hostname'],
				:topLevel_group => "/JPetStore Agents"
			}
		}
	)
	action :create
end

bash 'create Resources' do
  code <<-EOH
curl -s -X PUT -u admin:admin -d @#{Chef::Config['file_cache_path']}/topLevelResource.json https://#{node['UCD']['server_hostname']}:8443/cli/resource/create --insecure
curl -s -X PUT -u admin:admin -d @#{Chef::Config['file_cache_path']}/agentResource.json https://#{node['UCD']['server_hostname']}:8443/cli/resource/create --insecure
  EOH
end

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

ruby_block 'get agent id' do
	block do
		require 'net/http'
		require 'json'
		require 'uri'
		
		uri = URI.parse("https://#{node['UCD']['server_hostname']}:8443/cli/agentCLI/info?agent=#{node['ec2']['public_hostname']}")
		
		http = Net::HTTP.new(uri.host, uri.port)
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		http.use_ssl = true
		
		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth("admin", "admin")
		response = http.request(request)
		
		agent = JSON.parse(response.body)
		node.default['UCD']['agent_id'] = agent['id']

	end
	action :run
end

template 'JPetStore-APP Comp json file' do
	path "#{Chef::Config['file_cache_path']}/compVersionConfig.json"
	source "compVersionConfig.json.erb"
  	variables (
		lazy {
			{
				:comp_name	=> 'JPetStore-APP',
				:comp_base	=> 'app',
				:agent_id	=> node['UCD']['agent_id'] ,
				:tempdir	=> "#{Chef::Config['file_cache_path']}"
				
			}
		}
	)
	action :create
end

execute 'JPetStore-APP Comp' do
	command "curl -s -X PUT -b #{node['UCD']['cookies']} -c #{node['UCD']['cookies']} -u admin:admin -d @#{Chef::Config['file_cache_path']}/compVersionConfig.json https://#{node['UCD']['server_hostname']}:8443/rest/deploy/component --insecure"
	action :run
end

template 'JPetStore-DB Comp json file' do
	path "#{Chef::Config['file_cache_path']}/compVersionConfig.json"
	source "compVersionConfig.json.erb"
  	variables (
		lazy {
			{
				:comp_name	=> 'JPetStore-DB',
				:comp_base	=> 'db',
				:agent_id	=> node['UCD']['agent_id'] ,
				:tempdir	=> "#{Chef::Config['file_cache_path']}"
				
			}
		}
	)
	action :create
end

execute 'JPetStore-DB Comp' do
	command "curl -s -X PUT -b #{node['UCD']['cookies']} -c #{node['UCD']['cookies']} -u admin:admin -d @#{Chef::Config['file_cache_path']}/compVersionConfig.json https://#{node['UCD']['server_hostname']}:8443/rest/deploy/component --insecure"
	action :run
end

template 'JPetStore-WEB Comp json file' do
	path "#{Chef::Config['file_cache_path']}/compVersionConfig.json"
	source "compVersionConfig.json.erb"
  	variables (
		lazy {
			{
				:comp_name	=> 'JPetStore-WEB',
				:comp_base	=> 'web',
				:agent_id	=> node['UCD']['agent_id'] ,
				:tempdir	=> "#{Chef::Config['file_cache_path']}"
				
			}
		}
	)
	action :create
end

execute 'JPetStore-WEB Comp' do
	command "curl -s -X PUT -b #{node['UCD']['cookies']} -c #{node['UCD']['cookies']} -u admin:admin -d @#{Chef::Config['file_cache_path']}/compVersionConfig.json https://#{node['UCD']['server_hostname']}:8443/rest/deploy/component --insecure"
	action :run
end

template 'compVersionAPP.json' do
	path "#{Chef::Config['file_cache_path']}/compVersionAPP.json"
	source "compVersion.json.erb"
  	variables (
		lazy {
			{
				:comp_name	=> 'JPetStore-APP'
			}
		}
	)
	action :create
end


template 'compVersionDB.json' do
	path "#{Chef::Config['file_cache_path']}/compVersionDB.json"
	source "compVersion.json.erb"
  	variables (
		lazy {
			{
				:comp_name	=> 'JPetStore-DB'
			}
		}
	)
	action :create
end

template 'compVersionWEB.json' do
	path "#{Chef::Config['file_cache_path']}/compVersionWEB.json"
	source "compVersion.json.erb"
  	variables (
		lazy {
			{
				:comp_name	=> 'JPetStore-WEB'
			}
		}
	)
	action :create
end

cookbook_file "JPetStore-APP-Process.json" do
    path "#{Chef::Config['file_cache_path']}/JPetStore-APP-Process.json"
    action :create
end

cookbook_file "JPetStore-DB-Process.json" do
    path "#{Chef::Config['file_cache_path']}/JPetStore-DB-Process.json"
    action :create
end

cookbook_file "JPetStore-WEB-Process.json" do
    path "#{Chef::Config['file_cache_path']}/JPetStore-WEB-Process.json"
    action :create
end

bash 'petStore' do
	code <<-EOH
curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/compVersionAPP.json https://#{node['UCD']['server_hostname']}:8443/cli/component/integrate --insecure
curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/compVersionDB.json https://#{node['UCD']['server_hostname']}:8443/cli/component/integrate --insecure
curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/compVersionWEB.json https://#{node['UCD']['server_hostname']}:8443/cli/component/integrate --insecure

curl -s -X PUT -u admin:admin -d @#{Chef::Config['file_cache_path']}/JPetStore-APP-Process.json https://#{node['UCD']['server_hostname']}:8443/cli/componentProcess/create --insecure
curl -s -X PUT -u admin:admin -d @#{Chef::Config['file_cache_path']}/JPetStore-DB-Process.json  https://#{node['UCD']['server_hostname']}:8443/cli/componentProcess/create --insecure
curl -s -X PUT -u admin:admin -d @#{Chef::Config['file_cache_path']}/JPetStore-WEB-Process.json https://#{node['UCD']['server_hostname']}:8443/cli/componentProcess/create --insecure
	EOH
end

template "#{Chef::Config['file_cache_path']}/app.json" do
	source "app.json.erb"  	
	variables ({
		:app_name => "JPetStore"
	})
	action :create
end

bash 'petStore1' do
	code <<-EOH
AGENT_RESOURCE="JPetStore+Agents"

curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/app.json https://#{node['UCD']['server_hostname']}:8443/cli/application/create --insecure

curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/application/addComponentToApp?component=JPetStore-APP&application=JPetStore" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/application/addComponentToApp?component=JPetStore-DB&application=JPetStore" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/application/addComponentToApp?component=JPetStore-WEB&application=JPetStore" --insecure

curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=JPetStore&name=PROD-TX&color=#00B2EF" --insecure

curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=tomcat.home&value=/var/lib/tomcat7" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=db.url&value=jdbc:mysql://localhost:3306/jpetstore" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=tomcat.manager.url&value=http://localhost:8080/manager/text" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/propValue?application=JPetStore&environment=DEV-1&name=tomcat.start&value=/usr/share/tomcat7/bin/startup.sh" --insecure

curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/addBaseResource?application=JPetStore&environment=DEV-1&resource=/$AGENT_RESOURCE" --insecure
	EOH
end

template "#{Chef::Config['file_cache_path']}/compResource.json" do
	source "compResource.json.erb"
  	variables (
		lazy {
			{
				:comp_name => "JPetStore-APP",
				:agent_hostname => node['ec2']['public_hostname'],
				:parent_resource => "JPetStore Agents"
			}
		}
	)
	action :create
end

bash 'compResource JPetStore-APP' do
  code <<-EOH
curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/compResource.json https://#{node['UCD']['server_hostname']}:8443/cli/resource/create --insecure
  EOH
end

template "#{Chef::Config['file_cache_path']}/compResource.json" do
	source "compResource.json.erb"
  	variables (
		lazy {
			{
				:comp_name => "JPetStore-DB",
				:agent_hostname => node['ec2']['public_hostname'],
				:parent_resource => "JPetStore Agents"
			}
		}
	)
	action :create
end

bash 'compResource JPetStore-DB' do
  code <<-EOH
curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/compResource.json https://#{node['UCD']['server_hostname']}:8443/cli/resource/create --insecure
  EOH
end

template "#{Chef::Config['file_cache_path']}/compResource.json" do
	source "compResource.json.erb"
  	variables (
		lazy {
			{
				:comp_name => "JPetStore-WEB",
				:agent_hostname => node['ec2']['public_hostname'],
				:parent_resource => "JPetStore Agents"
			}
		}
	)
	action :create
end

cookbook_file "applicationProcess.json" do
    path "#{Chef::Config['file_cache_path']}/applicationProcess.json"
    action :create
end

cookbook_file "runApplicationProcess.json" do
    path "#{Chef::Config['file_cache_path']}/runApplicationProcess.json"
    action :create
end

bash 'compResource JPetStore-WEB' do
  code <<-EOH
curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/compResource.json https://#{node['UCD']['server_hostname']}:8443/cli/resource/create --insecure

curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/applicationProcess.json https://#{node['UCD']['server_hostname']}:8443/cli/applicationProcess/create --insecure

sleep 1m
result=`curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/runApplicationProcess.json https://#{node['UCD']['server_hostname']}:8443/cli/applicationProcessRequest/request --insecure`
REQUEST_ID=`echo $result | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["requestId"];'`
sleep 2m
curl -s -X GET -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/applicationProcessRequest/requestStatus?request=$REQUEST_ID" --insecure
  EOH
end

template "#{Chef::Config['file_cache_path']}/app.json" do
	source "app.json.erb"  	
	variables ({
		:app_name => "Pet Grooming Reservations"
	})
	action :create
end

bash 'deploy' do
  code <<-EOH
curl -s -X PUT -u admin:admin https://#{node['UCD']['server_hostname']}:8443/cli/application/create -d @#{Chef::Config['file_cache_path']}/app.json --insecure
APP="Pet%20Grooming%20Reservations"
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure
  EOH
end

template "#{Chef::Config['file_cache_path']}/app.json" do
	source "app.json.erb"  	
	variables ({
		:app_name => "Pet Transport"
	})
	action :create
end

bash 'deploy' do
  code <<-EOH
curl -s -X PUT -u admin:admin https://#{node['UCD']['server_hostname']}:8443/cli/application/create -d @#{Chef::Config['file_cache_path']}/app.json --insecure
APP="Pet+Transport"	
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure
  EOH
end
	
template "#{Chef::Config['file_cache_path']}/app.json" do
	source "app.json.erb"  	
	variables ({
		:app_name => "Pet Breeder Site"
	})
	action :create
end

bash 'deploy' do
  code <<-EOH
curl -s -X PUT -u admin:admin https://#{node['UCD']['server_hostname']}:8443/cli/application/create -d @#{Chef::Config['file_cache_path']}/app.json --insecure
APP="Pet+Breeder+Site"	
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure
  EOH
end

template "#{Chef::Config['file_cache_path']}/app.json" do
	source "app.json.erb"  	
	variables ({
		:app_name => "Pet Sourcing"
	})
	action :create
end

bash 'deploy' do
  code <<-EOH	
curl -s -X PUT -u admin:admin https://#{node['UCD']['server_hostname']}:8443/cli/application/create -d @#{Chef::Config['file_cache_path']}/app.json --insecure
APP="Pet+Sourcing"	
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['UCD']['server_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure
  EOH
end