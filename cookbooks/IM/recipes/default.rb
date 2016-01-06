include_recipe "libarchive::default"

remote_file "#{Chef::Config['file_cache_path']}/#{node['IM']['zip']}" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/IM/#{node['IM']['zip']}"
	action :create
	notifies :extract, 'libarchive_file[unzip IM zip]', :immediately
end

libarchive_file "unzip IM zip" do
  path "#{Chef::Config['file_cache_path']}/#{node['IM']['zip']}"
  extract_to "#{Chef::Config['file_cache_path']}/IBMIM"
  action :nothing
end

execute 'install IM' do
  user 'root'
  command "#{Chef::Config['file_cache_path']}/IBMIM/installc -acceptLicense --launcher.ini #{Chef::Config['file_cache_path']}/IBMIM/silent-install.ini"
end

execute 'upgrade IM' do
  user 'root'
  command "/opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.cic.agent"
end
