include_recipe "libarchive::default"
include_recipe "IM::default"

remote_file "download rdm zip" do
    path "#{Chef::Config['file_cache_path']}/#{node['CLM']['rdm_zip']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['rdm_zip']}"
	action :create
	notifies :extract, 'libarchive_file[unzip rdm zip]', :immediately
	only_if { node['CLM']['use_rdm'] }
end

libarchive_file "unzip rdm zip" do
  path "#{Chef::Config['file_cache_path']}/#{node['CLM']['rdm_zip']}"
  extract_to "#{Chef::Config['file_cache_path']}/RDM"
  action :nothing
  notifies :run, 'execute[rdm Installation]', :immediately
end

service 'JTS' do
	action [ :stop ]
end

execute 'rdm Installation' do
  user 'root'
  command "ulimit -n 65536;/opt/IBM/InstallationManager/eclipse/tools/imcl install #{node['CLM'][:rdm_packages]} -repositories #{Chef::Config['file_cache_path']}/RDM/RhapsodyDM_Server/disk1/diskTag.inf -acceptLicense"
  action :nothing
end

service 'JTS' do
	action [ :start ]
end