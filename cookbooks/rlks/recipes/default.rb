include_recipe "im::default"

remote_file "RLKS_8.1.4_FOR_LINUX_X86_ML.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/RLKS_8.1.4_FOR_LINUX_X86_ML.zip"
	path '/vagrant/RLKS_8.1.4_FOR_LINUX_X86_ML.zip'
	mode '0755'
	action :create_if_missing
end

execute 'unzip' do
  user 'root'
  command 'unzip /vagrant/RLKS_8.1.4_FOR_LINUX_X86_ML.zip -d /tmp/RLKS > /dev/null'
end

execute 'install' do
  user 'root'
  command '/opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.rational.license.key.server.linux.x86_8.1.4000.20130823_0513 -repositories /tmp/RLKS/RLKSSERVER_SETUP_LINUX_X86/disk1/diskTag.inf -acceptLicense'
end
