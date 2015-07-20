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
	action :create_if_missing
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
  notifies :run, 'execute[starting JTS Server]', :immediately
end

directory "/opt/IBM/JazzTeamServer/server/patch" do
  only_if { node['CLM']['fix'] != 'nil' }
  action :create
  notifies :create, 'remote_file[Download CLM Fix]', :immediately
end

remote_file "Download CLM Fix" do
    path "/opt/IBM/JazzTeamServer/server/patch/#{node['CLM']['fix']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['fix']}"
	action :nothing
end

execute 'starting JTS Server' do
  user 'root'
  environment "DISPLAY" => "localhost:1.0"
  command "/opt/IBM/JazzTeamServer/server/server.startup"
  action :nothing
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
