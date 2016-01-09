include_recipe "apt"
include_recipe "java7"
include_recipe "libarchive"
include_recipe "IM"

clm_servers = search(:node, 'role:clm-server')

if ( clm_servers.empty? or node[:roles].include?('clm_server') )
	node.default['CLM']['server_hostname']		= node['ec2']['public_hostname']
else
    node.default['CLM']['server_hostname']		= clm_servers[0].cloud.public_hostname
end

remote_file "download build toolkit zip" do
    path "#{Chef::Config['file_cache_path']}/#{node['CLM']['build_zip']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['build_zip']}"
	action :create
	notifies :extract, 'libarchive_file[Extract build toolkit zip]', :immediately
	only_if { node['CLM']['use_build'] }
end

libarchive_file "Extract build toolkit zip" do
	path "#{Chef::Config['file_cache_path']}/#{node['CLM']['build_zip']}"
	extract_to "#{Chef::Config['file_cache_path']}/BUILD"
	action :nothing
	notifies :run, 'execute[build toolkit installation]', :immediately
	only_if { node['CLM']['use_build'] }
end

execute 'build toolkit installation' do
	user 'root'
	command "/opt/IBM/InstallationManager/eclipse/tools/imcl install #{node['CLM'][:build_packages]} -repositories #{Chef::Config['file_cache_path']}/BUILD/im/repo/rtc-buildsystem-offering/offering-repo/repository.config -acceptLicense"
	action :nothing
	only_if { node['CLM']['use_build'] }
end

execute 'Run jbe' do
	user 'root'
	command "/opt/IBM/TeamConcertBuild/buildsystem/buildengine/eclipse/jbe.sh -repository https://#{node['CLM']['server_hostname']}:9443/ccm -userId build -pass build -engineId jke.dev.engine &"
	action :run
	only_if { node['CLM']['use_build'] }
end