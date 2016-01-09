include_recipe "libarchive::default"
include_recipe "IM::default"

remote_file "Download rdm zip" do
    path "#{Chef::Config['file_cache_path']}/#{node['CLM']['rdm_zip']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['rdm_zip']}"
	action :create
	notifies :extract, 'libarchive_file[Extract rdm zip]', :immediately
	only_if { node['CLM']['use_rdm'] }
end

libarchive_file "Extract rdm zip" do
  path "#{Chef::Config['file_cache_path']}/#{node['CLM']['rdm_zip']}"
  extract_to "#{Chef::Config['file_cache_path']}/RDM"
  action :nothing
	only_if { node['CLM']['use_rdm'] }
end

service 'JTS' do
	action :stop
	only_if { node['CLM']['use_rdm'] }
end

execute 'rdm Installation' do
	user 'root'
	command "/opt/IBM/InstallationManager/eclipse/tools/imcl install #{node['CLM'][:rdm_packages]} -repositories #{Chef::Config['file_cache_path']}/RDM/RhapsodyDM_Server/disk1/diskTag.inf -acceptLicense"
	action :run
	only_if { node['CLM']['use_rdm'] }
end

directory "/opt/IBM/JazzTeamServer/server/patch" do
	not_if { node['CLM']['rdm_fix'].to_s == '' }
	action :create
end

directory "/opt/IBM/JazzTeamServer/server/conf/dm/patch" do
	not_if { node['CLM']['rdm_fix'].to_s == '' }
	recursive true
	action :delete
end

remote_file "Download RDM Fix" do
	not_if { node['CLM']['rdm_fix'].to_s == '' }
    path "#{Chef::Config['file_cache_path']}/#{node['CLM']['rdm_fix']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['rdm_fix']}"
	action :create
end

libarchive_file "Extract RDM fix zip" do
	not_if { node['CLM']['rdm_fix'].to_s == '' }
	path "#{Chef::Config['file_cache_path']}/#{node['CLM']['rdm_fix']}"
	extract_to "#{Chef::Config['file_cache_path']}/RDM_FIX"
	action :extract
end

remote_file "Copy RDM server patch" do 
	not_if { node['CLM']['rdm_fix'].to_s == '' }
	path "/opt/IBM/JazzTeamServer/server/patch/#{node['CLM']['rdm_server_patch']}" 
	source "file://#{Chef::Config['file_cache_path']}/RDM_FIX/#{node['CLM']['rdm_server_patch']}"
end

directory "/opt/IBM/JazzTeamServer/RhapsodyModelServer" do
	not_if { node['CLM']['RhapsodyModelServer_fix'].to_s == '' }
	recursive true
	action :delete
end

remote_file "Download RhapsodyModelServer Fix" do
	not_if { node['CLM']['RhapsodyModelServer_fix'].to_s == '' }
    path "#{Chef::Config['file_cache_path']}/#{node['CLM']['RhapsodyModelServer_fix']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['RhapsodyModelServer_fix']}"
	action :create
end

libarchive_file "Extract RhapsodyModelServer fix zip" do
	not_if { node['CLM']['RhapsodyModelServer_fix'].to_s == '' }
	path "#{Chef::Config['file_cache_path']}/#{node['CLM']['RhapsodyModelServer_fix']}"
	extract_to "#{Chef::Config['file_cache_path']}/RHAP_DM_FIX"
	action :extract
end

libarchive_file  "Extract RhapsodyModelServer linux fix" do 
	not_if { node['CLM']['RhapsodyModelServer_fix'].to_s == '' }
	path "#{Chef::Config['file_cache_path']}/RHAP_DM_FIX/#{node['CLM']['RhapsodyModelServer_linux_fix']}"
	extract_to "/opt/IBM/JazzTeamServer/RhapsodyModelServer"
	action :extract
end

service 'JTS' do
	action :start
	only_if { node['CLM']['use_rdm'] }
end