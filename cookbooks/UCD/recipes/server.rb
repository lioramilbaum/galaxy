include_recipe "libarchive::default"
include_recipe "java7::default"

remote_file "ec2-metadata" do
	source "http://s3.amazonaws.com/ec2metadata/ec2-metadata"
	action :create
end

remote_file "#{Chef::Config['file_cache_path']}/#{node['UCD']['zip']}" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCD/#{node['UCD']['zip']}"
	action :create
	notifies :extract, 'libarchive_file[Extracting UCD zip]', :immediately
end

libarchive_file "Extracting UCD zip" do
  path "#{Chef::Config['file_cache_path']}/#{node['UCD']['zip']}"
  extract_to "#{Chef::Config['file_cache_path']}/UCD"
  action :nothing
end

template "#{Chef::Config['file_cache_path']}/UCD/ibm-ucd-install/install.properties" do
	source "server.install.properties.erb"
  	variables (
		lazy {
			{
				:server_hostname => node['ec2']['public_hostname'],
				:initial_password => node['UCD']['initial_password']
			}
		}
	)
	action :create
end

execute "#{Chef::Config['file_cache_path']}/UCD/ibm-ucd-install/install-server.sh" do
  user 'root'
  action :run
end

["#{node['UCD']['plugins_dir']}/command/stage","#{node['UCD']['plugins_dir']}/source/stage"].each do |path|
  directory path do
    action :create
    recursive true
  end
end

remote_file "#{node['UCD']['plugins_dir']}/command/stage/DBUpgrader-2.641649.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCD-Plugins/DBUpgrader-2.641649.zip"
	action :create
end

remote_file "#{node['UCD']['plugins_dir']}/command/stage/Tomcat-5.641593.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCD-Plugins/Tomcat-5.641593.zip"
	action :create
end

remote_file "#{node['UCD']['plugins_dir']}/command/stage/Artifactory-1.619009.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCD-Plugins/Artifactory-1.619009.zip"
	action :create
end

remote_file "#{node['UCD']['plugins_dir']}/source/stage/ArtifactorySourceConfig-2.641670.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCD-Plugins/ArtifactorySourceConfig-2.641670.zip"
	action :create
end

remote_file "#{node['UCD']['plugins_dir']}/command/stage/AmazonEC2-5.641618.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCD-Plugins/AmazonEC2-5.641618.zip"
	action :create
end

execute 'server start' do
  user 'root'
  command "/opt/ibm-ucd/server/bin/server start"
  action :run
end

execute 'sleep' do
  command "sleep 1m"
  action :run
end

libarchive_file "ibm-ucd-agent.zip" do
  path "/opt/ibm-ucd/server/opt/tomcat/webapps/ROOT/tools/ibm-ucd-agent.zip"
  extract_to "#{Chef::Config['file_cache_path']}/UCD_AGENT"
  action :extract
end

template "#{Chef::Config['file_cache_path']}/agent.properties" do
	source "agent.properties.erb" 
  	variables (
		lazy {
			{
				:server_hostname => node['ec2']['public_hostname'],
				:agent_hostname => node['ec2']['public_hostname']
			}
		}
	)
  action :create
end

execute 'install-agent-from-file.sh' do
  command "#{Chef::Config['file_cache_path']}/UCD_AGENT/ibm-ucd-agent-install/install-agent-from-file.sh #{Chef::Config['file_cache_path']}/agent.properties"
  action :run
end

execute 'agent start' do
  user 'root'
  command "/opt/ibm-ucd/agent/bin/agent start"
  action :run
end

execute 'sleep' do
  command "sleep 1m"
  action :run
end

execute 'Dismiss Alret' do
  command "curl -s -X POST -u admin:admin https://#{node['ec2']['public_hostname']}:8443/rest/security/userPreferences/dismissAlert/dismissed_dw --insecure"
  action :run
end

template "#{Chef::Config['file_cache_path']}/agent.json" do
	source "agent.json.erb" 
  	variables (
		lazy {
			{
				:agent_hostname => node['ec2']['public_hostname']
			}
		}
	)
	action :create
	notifies :run, 'execute[Configure Agent]', :immediately
end

execute 'Configure Agent' do
  command "curl -s -X PUT -u admin:admin  -d @#{Chef::Config['file_cache_path']}/agent.json https://#{node['ec2']['public_hostname']}:8443/cli/systemConfiguration --insecure"
  action :nothing
end

execute 'Configure1 Agent' do
  command "curl -s -X PUT -u admin:admin https://#{node['UCD']['server_hostname']}:8443/cli/teamsecurity/tokens?user=admin&expireDate=12-31-2020-00:24"
  action :run
end

template "#{Chef::Config['file_cache_path']}/topLevelResource.json" do
	source "topLevelResource.json.erb" 
	variables ({
		:topLevel_group => "Server Agent"
	})
	action :create
end

template "#{Chef::Config['file_cache_path']}/agentResource.json" do
	source "agentResource.json.erb" 
  	variables (
		lazy {
			{
				:agent_hostname => node['ec2']['public_hostname'],
				:topLevel_group => "/Server Agent"
			}
		}
	)
	action :create
end

bash 'create Resources' do
  code <<-EOH
curl -s -X PUT -u admin:admin -d @#{Chef::Config['file_cache_path']}/topLevelResource.json https://#{node['ec2']['public_hostname']}:8443/cli/resource/create --insecure
curl -s -X PUT -u admin:admin -d @#{Chef::Config['file_cache_path']}/agentResource.json https://#{node['ec2']['public_hostname']}:8443/cli/resource/create --insecure
  EOH
end
