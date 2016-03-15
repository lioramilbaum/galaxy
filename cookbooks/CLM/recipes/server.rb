include_recipe "libarchive::default"
include_recipe "IM::default"

package ['xvfb','xfonts-100dpi','xfonts-75dpi','xfonts-scalable','xfonts-cyrillic','libgtk2.0-0', 'libstdc++5', 'libswt-gtk-3-jni', 'libswt-gtk-3-java'] do
  action :install
end

remote_file "Download CLM" do
    path "#{Chef::Config['file_cache_path']}/#{node['CLM']['clm_zip']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['clm_zip']}"
	action :create
	notifies :extract, 'libarchive_file[Extract CLM zip]', :immediately
end

libarchive_file "Extract CLM zip" do
  path "#{Chef::Config['file_cache_path']}/#{node['CLM']['clm_zip']}"
  extract_to "#{Chef::Config['file_cache_path']}/CLM"
  action :nothing
  notifies :run, 'execute[CLM Installation]', :immediately
end

execute 'CLM Installation' do
  user 'root'
  command "/opt/IBM/InstallationManager/eclipse/tools/imcl install #{node['CLM']['clm_packages']} -repositories #{Chef::Config['file_cache_path']}/CLM/repository.config -acceptLicense"
  action :nothing
end

directory "/opt/IBM/JazzTeamServer/server/patch" do
	not_if { node['CLM']['clm_fix'].to_s == '' }
	action :create
	notifies :create, 'remote_file[Download CLM Fix]', :immediately
end

remote_file "Download CLM Fix" do
	not_if { node['CLM']['clm_fix'].to_s == '' }
    path "#{Chef::Config['file_cache_path']}/#{node['CLM']['clm_fix']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['clm_fix']}"
	action :create
    notifies :extract, 'libarchive_file[Extract CLM fix zip]', :immediately
end

libarchive_file "Extract CLM fix zip" do
	not_if { node['CLM']['clm_fix'].to_s == '' }
	path "#{Chef::Config['file_cache_path']}/#{node['CLM']['clm_fix']}"
	extract_to "#{Chef::Config['file_cache_path']}/CLM_FIX"
	action :nothing
	notifies :create, 'remote_file[Copy CLM server patch]', :immediately
end

clm_fix_basename = File.basename("#{node['CLM']['clm_fix']}", ".zip")

remote_file "Copy CLM server patch" do 
	not_if { node['CLM']['clm_fix'].to_s == '' }
	path "/opt/IBM/JazzTeamServer/server/patch/#{node['CLM']['clm_server_patch']}" 
	source "file://#{Chef::Config['file_cache_path']}/CLM_FIX/#{clm_fix_basename}/#{node['CLM']['clm_server_patch']}"
end

remote_file "Copy rs.war" do
	not_if { node['CLM']['clm_fix'].to_s == '' }
	path "/opt/IBM/JazzTeamServer/server/liberty/clmServerTemplate/apps/rs.war.zip" 
	source "file://#{Chef::Config['file_cache_path']}/CLM_FIX/#{clm_fix_basename}/rs.war"
end

libarchive_file "Extract rs.war.zip" do
	not_if { node['CLM']['clm_fix'].to_s == '' }
	path "/opt/IBM/JazzTeamServer/server/liberty/clmServerTemplate/apps/rs.war.zip"
	extract_to "/opt/IBM/JazzTeamServer/server/liberty/clmServerTemplate/apps/rs.war"
	action :extract
end

Dir['/opt/IBM/JazzTeamServer/server/conf/dcc/mapping/*'].each do |path|
	file path do
		action :delete
	end
end

libarchive_file "Extract mapping file" do
	not_if { node['CLM']['clm_fix'].to_s == '' }
	path "#{Chef::Config['file_cache_path']}/CLM_FIX/#{clm_fix_basename}/#{node['CLM']['clm_mapping_file']}"
	extract_to "/opt/IBM/JazzTeamServer/server/conf/dcc/mapping"
	action :extract
end

remote_file "Copy ldx.war" do 
	not_if { node['CLM']['clm_fix'].to_s == '' }
	path "/opt/IBM/JazzTeamServer/server/liberty/clmServerTemplate/apps/ldx.war.zip" 
	source "file://#{Chef::Config['file_cache_path']}/CLM_FIX/#{clm_fix_basename}/ldx.war"
end

libarchive_file "Extract ldx.war.zip" do
	not_if { node['CLM']['clm_fix'].to_s == '' }
	path "/opt/IBM/JazzTeamServer/server/liberty/clmServerTemplate/apps/ldx.war.zip"
	extract_to "/opt/IBM/JazzTeamServer/server/liberty/clmServerTemplate/apps/ldx.war"
	action :extract
end

remote_file "Copy lqe.war" do 
	not_if { node['CLM']['clm_fix'].to_s == '' }
	path "/opt/IBM/JazzTeamServer/server/liberty/clmServerTemplate/apps/lqe.war.zip" 
	source "file://#{Chef::Config['file_cache_path']}/CLM_FIX/#{clm_fix_basename}/lqe.war"
end

libarchive_file "Extract lqe.war.zip" do
	not_if { node['CLM']['clm_fix'].to_s == '' }
	path "/opt/IBM/JazzTeamServer/server/liberty/clmServerTemplate/apps/lqe.war.zip"
	extract_to "/opt/IBM/JazzTeamServer/server/liberty/clmServerTemplate/apps/lqe.war"
	action :extract
end

template "Setup JTS.conf" do
  path "/etc/init/JTS.conf"
  source 'JTS.conf.erb'
  action :create
end

service 'JTS' do
	provider Chef::Provider::Service::Upstart
	supports :start => true, :stop => true
	action [ :enable, :start ]
end