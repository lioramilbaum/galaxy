include_recipe "im::default"
include_recipe "rlks::default"

remote_file "IBM_URBANCODE_RELEASE_6.1.1_FOR_L.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCR/URBANCODE_RELEASE_6.1.1_AIX_EN_EV.iso"
	path '/vagrant/URBANCODE_RELEASE_6.1.1_AIX_EN_EV.iso'
	mode '0755'
	action :create_if_missing
end

directory "/mnt/iso" do
  owner 'root'
  group 'root'
  action :create
end

mount "/mnt/iso" do
  device '/vagrant/URBANCODE_RELEASE_6.1.1_AIX_EN_EV.iso'
  options  'loop'
  action :mount
end

execute 'install' do
  user 'root'
  command 'sudo /opt/IBM/InstallationManager/eclipse/tools/imcl -nl en_US install com.ibm.urbancode.urelease_6.1.1004.UCRELO6114-I20150216_1529 -repositories /mnt/iso/diskTag.inf -acceptLicense'
end

=begin
execute 'server.startup' do
  user 'root'
  cwd '/opt/IBM/UCRelease/server'
  command 'sudo /opt/IBM/UCRelease/server/server.startup'
end
=end