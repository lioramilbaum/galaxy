include_recipe "libarchive::default"

remote_file "/tmp/#{node['IM']['zip']}" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/IM/#{node['IM']['zip']}"
	action :create
	notifies :extract, 'libarchive_file[unzip IM zip]', :immediately
end

libarchive_file "unzip IM zip" do
  path "/tmp/#{node['IM']['zip']}"
  extract_to "/tmp/IBMIM"
  action :nothing
end

execute 'install IM' do
  user 'root'
  command '/tmp/IBMIM/installc -acceptLicense --launcher.ini /tmp/IBMIM/silent-install.ini'
end

execute 'upgrade IM' do
  user 'root'
  command '/opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.cic.agent'
end
