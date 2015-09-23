include_recipe "libarchive::default"
include_recipe "IM::default"

remote_file "download build toolkit zip" do
    path "#{Chef::Config['file_cache_path']}/#{node['CLM']['build_zip']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['build_zip']}"
	action :create
	notifies :extract, 'libarchive_file[unzip build toolkit zip]', :immediately
	only_if { node['CLM']['use_build'] }
end

libarchive_file "unzip build toolkit zip" do
  path "#{Chef::Config['file_cache_path']}/#{node['CLM']['build_zip']}"
  extract_to "#{Chef::Config['file_cache_path']}/BUILD"
  action :nothing
  notifies :run, 'execute[build toolkit installation]', :immediately
end

execute 'build toolkit installation' do
  user 'root'
  command "/opt/IBM/InstallationManager/eclipse/tools/imcl install #{node['CLM'][:build_packages]} -repositories #{Chef::Config['file_cache_path']}/BUILD/im/repo/rtc-buildsystem-offering/offering-repo/repository.config -acceptLicense"
  action :nothing
end

execute 'Run jbe' do
  user 'root'
  command "/opt/IBM/TeamConcertBuild/buildsystem/buildengine/eclipse/jbe.sh -repository https://#{node['CLM']['server_hostname']}:9443/ccm -userId build -pass build -engineId jke.dev.engine &"
  action :run
end