include_recipe "libarchive::default"
include_recipe "IM::default"
include_recipe "CLM::rdm"

package ['xvfb','xfonts-100dpi','xfonts-75dpi','xfonts-scalable','xfonts-cyrillic','libgtk2.0-0', 'libstdc++5', 'libswt-gtk-3-jni', 'libswt-gtk-3-java'] do
  action :install
end

remote_file "Download CLM" do
    path "#{Chef::Config['file_cache_path']}/#{node['CLM']['zip']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['zip']}"
	action :create
	notifies :extract, 'libarchive_file[unzip CLM zip]', :immediately
end

libarchive_file "unzip CLM zip" do
  path "#{Chef::Config['file_cache_path']}/#{node['CLM']['zip']}"
  extract_to "#{Chef::Config['file_cache_path']}/CLM"
  action :nothing
  notifies :run, 'execute[CLM Installation]', :immediately
end

execute 'CLM Installation' do
  user 'root'
  command "/opt/IBM/InstallationManager/eclipse/tools/imcl install #{node['CLM'][:packages]} -repositories #{Chef::Config['file_cache_path']}/CLM/repository.config -acceptLicense"
  action :nothing
end

directory "/opt/IBM/JazzTeamServer/server/patch" do
  not_if { node['CLM']['fix'].nil? }
  action :create
  notifies :create, 'remote_file[Download CLM Fix]', :immediately
end

remote_file "Download CLM Fix" do
    path "#{Chef::Config['file_cache_path']}/#{node['CLM']['fix']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['fix']}"
	action :create
    notifies :extract, 'libarchive_file[unzip CLM fix zip]', :immediately
end

libarchive_file "unzip CLM fix zip" do
  path "#{Chef::Config['file_cache_path']}/#{node['CLM']['fix']}"
  extract_to "#{Chef::Config['file_cache_path']}/CLM_FIX"
  action :nothing
  notifies :create, 'remote_file[Copy CLM fix zip]', :immediately
end

remote_file "Copy CLM fix zip" do 
  path "/opt/IBM/JazzTeamServer/server/patch/#{node['CLM']['fix_package']}" 
  source "file://#{Chef::Config['file_cache_path']}/CLM_FIX/#{node['CLM']['fix_package']}"
end

remote_file "Copy rs.war" do 
  path "/opt/IBM/JazzTeamServer/server/tomcat/webapps/rs.war" 
  source "file://#{Chef::Config['file_cache_path']}/CLM_FIX/rs.war"
end

remote_file "Copy ldx.war" do 
  path "/opt/IBM/JazzTeamServer/server/tomcat/webapps/ldx.war" 
  source "file://#{Chef::Config['file_cache_path']}/CLM_FIX/ldx.war"
end

remote_file "Copy lqe.war" do 
  path "/opt/IBM/JazzTeamServer/server/tomcat/webapps/lqe.war" 
  source "file://#{Chef::Config['file_cache_path']}/CLM_FIX/lqe.war"
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