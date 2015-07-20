include_recipe "libarchive::default"
include_recipe "IM::default"

remote_file "download rdm zip" do
    path "/tmp/#{node['CLM']['rdm_zip']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/CLM/#{node['CLM']['rdm_zip']}"
	action :create
	notifies :extract, 'libarchive_file[unzip rdm zip]', :immediately
	only_if { node['CLM']['use_rdm'] }
end

libarchive_file "unzip rdm zip" do
  path "/tmp/#{node['CLM']['rdm_zip']}"
  extract_to "/tmp/RDM"
  action :nothing
  notifies :run, 'execute[rdm Installation]', :immediately
end

execute 'rdm Installation' do
  user 'root'
  command "/opt/IBM/InstallationManager/eclipse/tools/imcl install #{node['CLM'][:rdm_packages]} -repositories /tmp/RDM/RhapsodyDM_Server/disk1/diskTag.inf -acceptLicense"
  action :nothing
end