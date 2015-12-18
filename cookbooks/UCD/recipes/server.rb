include_recipe "libarchive::default"
include_recipe "java7::default"

cookbook_file "ucd_rsa.pub" do
	user 'ubuntu'
    path "/home/ubuntu/.ssh/ucd_rsa.pub"
    action :create
end

execute "copy ssh public key" do
    user 'ubuntu'
    command "cat /home/ubuntu/.ssh/ucd_rsa.pub >> /home/ubuntu/.ssh/authorized_keys"
    action :run
end

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
  notifies :create, 'template[install.properties]', :immediately
end

template "install.properties" do
	path "#{Chef::Config['file_cache_path']}/UCD/ibm-ucd-install/install.properties"
	source "server.install.properties.erb"
  	variables (
		lazy {
			{
				:server_hostname => node['ec2']['public_hostname'],
				:initial_password => node['UCD']['initial_password']
			}
		}
	)
	action :nothing
	notifies :run, 'execute[install server]', :immediately
end

execute "install server" do
	command "#{Chef::Config['file_cache_path']}/UCD/ibm-ucd-install/install-server.sh"
	user 'root'
	action :nothing
end

remote_file "#{Chef::Config['file_cache_path']}/#{node['UCD']['fix']}" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCD/#{node['UCD']['fix']}"
	action :create
	notifies :extract, 'libarchive_file[Extracting UCD fix]', :immediately
	only_if { node['UCD']['fix'] }
end

libarchive_file "Extracting UCD fix" do
  path "#{Chef::Config['file_cache_path']}/#{node['UCD']['fix']}"
  extract_to "#{Chef::Config['file_cache_path']}/UCD_FIX"
  action :nothing
  notifies :create, 'template[install.properties FIX]', :immediately 
end

template "install.properties FIX" do
	path "#{Chef::Config['file_cache_path']}/UCD_FIX/ibm-ucd-install/install.properties"
	source "server.fix.install.properties.erb"
  	variables (
		lazy {
			{
				:server_hostname => node['ec2']['public_hostname'],
				:initial_password => node['UCD']['initial_password']
			}
		}
	)
	action :nothing
	notifies :run, 'execute[install server FIX]', :immediately
end

execute "install server FIX" do
	command "#{Chef::Config['file_cache_path']}/UCD_FIX/ibm-ucd-install/install-server.sh"
	user 'root'
	action :nothing
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

remote_file "#{node['UCD']['plugins_dir']}/command/stage/#{node['UCD']['tomcat_plugin']}" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCD-Plugins/#{node['UCD']['tomcat_plugin']}"
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

execute 'Dismiss Alret' do
  command "curl -s -X POST -u admin:admin https://#{node['ec2']['public_hostname']}:8443/rest/security/userPreferences/dismissAlert/dismissed_dw --insecure"
  action :run
end