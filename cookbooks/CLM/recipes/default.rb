include_recipe "base::ubuntu" if node.key?("ec2")
include_recipe "apt::default"
include_recipe "libarchive::default"
include_recipe "IM::default"
include_recipe "CLM::rdm"

package 'xvfb' do
  action :install
  notifies :run, 'execute[xvfb]', :immediately
end

execute 'xvfb' do
  user 'root'
  command "Xvfb :1 -screen 0 800x600x24&"
  action :nothing
end

remote_file "Download CLM" do
    path "/tmp/#{node['CLM']['zip']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['zip']}"
	action :create
	notifies :extract, 'libarchive_file[unzip CLM zip]', :immediately
end

libarchive_file "unzip CLM zip" do
  path "/tmp/#{node['CLM']['zip']}"
  extract_to "/tmp/CLM"
  action :nothing
  notifies :run, 'execute[CLM Installation]', :immediately
end

execute 'CLM Installation' do
  user 'root'
  command "/opt/IBM/InstallationManager/eclipse/tools/imcl install #{node['CLM'][:packages]} -repositories /tmp/CLM/repository.config -acceptLicense"
  action :nothing
end

directory "/opt/IBM/JazzTeamServer/server/patch" do
  not_if { node['CLM']['fix'].nil? }
  action :create
  notifies :create, 'remote_file[Download CLM Fix]', :immediately
end

remote_file "Download CLM Fix" do
    path "/tmp/#{node['CLM']['fix']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['fix']}"
	action :create
    notifies :extract, 'libarchive_file[unzip CLM fix zip]', :immediately
end

libarchive_file "unzip CLM fix zip" do
  path "/tmp/#{node['CLM']['fix']}"
  extract_to "/tmp/CLM_FIX"
  action :nothing
  notifies :create, 'remote_file[Copy CLM fix zip]', :immediately
end

remote_file "Copy CLM fix zip" do 
  path "/opt/IBM/JazzTeamServer/server/patch/#{node['CLM']['fix_package']}" 
  source "file:///tmp/CLM_FIX/#{node['CLM']['fix_package']}"
end

remote_file "Copy rs.war" do 
  path "/opt/IBM/JazzTeamServer/server/tomcat/webapps/rs.war" 
  source "file:///tmp/CLM_FIX/rs.war"
end

directory "/opt/IBM/JazzTeamServer/server/tomcat/webapps/rs" do
  action :delete
  recursive true
end

remote_file "Copy ldx.war" do 
  path "/opt/IBM/JazzTeamServer/server/tomcat/webapps/ldx.war" 
  source "file:///tmp/CLM_FIX/ldx.war"
end

directory "/opt/IBM/JazzTeamServer/server/tomcat/webapps/ldx" do
  action :delete
  recursive true
end

remote_file "Copy lqe.war" do 
  path "/opt/IBM/JazzTeamServer/server/tomcat/webapps/lqe.war" 
  source "file:///tmp/CLM_FIX/lqe.war"
end

directory "/opt/IBM/JazzTeamServer/server/tomcat/webapps/lqe" do
  action :delete
  recursive true
end

execute 'starting JTS Server' do
  user 'root'
  environment "DISPLAY" => "localhost:1.0"
  command "/opt/IBM/JazzTeamServer/server/server.startup"
  action :run
  notifies :run, 'execute[sleep 3m]', :immediately
end

execute 'sleep 3m' do
  command "sleep 3m"
  action :nothing
end

template "Setup Properties File" do
  path "#{node['CLM'][:parametersfile]}"
  source 'CLM.properties.erb'
  variables ({
     :use_rdm => node['CLM']['use_rdm'],
     :server_hostname => node['CLM']['server_hostname']
  })
  action :create
  notifies :run, 'execute[CLM Setup]', :immediately
end

execute 'CLM Setup' do
  user 'root'
  cwd "/opt/IBM/JazzTeamServer/server"
  command "./repotools-jts.sh -setup includeLifecycleProjectStep=true parametersfile=#{node['CLM'][:parametersfile]}"
  action :nothing
  notifies :run, 'execute[Assign build license]', :immediately
end

execute 'Assign build license' do
  user 'root'
  cwd "/opt/IBM/JazzTeamServer/server"
  command "./repotools-jts.sh -createUser adminUserId=liora adminPassword=liora userId=build licenseId='com.ibm.team.rtc.buildsystem'"
  action :nothing
  returns [0,22]
end
