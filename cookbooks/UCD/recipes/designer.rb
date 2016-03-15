include_recipe 'libarchive::default'
include_recipe 'python'

ucd_servers = search(:node, 'role:ucd-server')
if ( ucd_servers.empty? or node[:roles].include?('ucd-server') )
	node.default['UCD']['server_hostname']	= node['ec2']['public_hostname']
else
    node.default['UCD']['server_hostname']	= ucd_servers[0].cloud.public_hostname
end


rcl_servers = search(:node, 'role:rcl_server')
if ( rcl_servers.empty? or node[:roles].include?('rcl_server') )
	node.default['UCD']['rcl_hostname']	= node['ec2']['public_hostname']
else
    node.default['UCD']['rcl_hostname']	= rcl_servers[0].cloud.public_hostname
end

remote_file "Download designer" do
    path "#{Chef::Config['file_cache_path']}/#{node['UCD']['designer_zip']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCD/#{node['UCD']['designer_zip']}"
	action :create
	notifies :extract, 'libarchive_file[unzip UCD designer zip]', :immediately
end

libarchive_file "unzip UCD designer zip" do
  path "#{Chef::Config['file_cache_path']}/#{node['UCD']['designer_zip']}"
  extract_to "#{Chef::Config['file_cache_path']}/UCD_DESIGNER"
  action :nothing
  notifies :run, 'execute[UCD designer Installation]', :immediately
end

execute 'UCD designer Installation' do
  user 'root'
  cwd "#{Chef::Config['file_cache_path']}/UCD_DESIGNER/ibm-ucd-patterns-install/web-install"
  command "./install.sh -l -i #{node['ec2']['public_hostname']} -o https://#{node['UCD']['server_hostname']}:8443 -e http://#{node['ec2']['public_hostname']}:7575 -d derby -r 27000:#{node['UCD']['rcl_hostname']}"
  action :nothing
end

cookbook_file 'cloud_discovery_file' do
	path "#{Chef::Config['file_cache_path']}/cloud_discovery_file"
	action :create
end

ENV['CLOUDDISCOVERYSERVICE_SETTINGS_FILE'] = "#{Chef::Config['file_cache_path']}/cloud_discovery_file"

bash "Stopping cloud discovery service" do
  code <<-EOH
    kill $(ps aux | grep -i -e "cloud" | grep -v "grep" | awk '{print $2}')
    cloud-discovery-service &
  EOH
end

service 'openstack-heat-engine' do
	action [ :restart ]
end

service 'openstack-heat-api' do
	action [ :restart ]
end

service 'openstack-heat-api-cfn' do
	action [ :restart ]
end

service 'openstack-heat-api-cloudwatch' do
	action [ :restart ]
end

service 'openstack-keystone' do
	action [ :start ]
end

execute 'designer start' do
  user 'root'
  command "/opt/ibm-ucd-patterns-install/web-install/server start"
  action :run
end

ENV['JAVA_HOME'] = '/opt/ibm-ucd-patterns-install/ibm-ucd-patterns-install/web-install/media/server/java/jre'

execute 'install agent packages' do
  cwd "#{Chef::Config['file_cache_path']}/UCD_DESIGNER/ibm-ucd-patterns-install/web-install"
  command "./install-agent-packages.sh -s https://['UCD']['server_hostname']:8443 -a token"
  action :run
end
