package [ 'unzip', 'gcc', 'gcc-c++', 'kernel-devel', 'mysql-devel', 'python-devel']  do
  action :install
end

package [ 'akonadi']  do
  action :remove
end

service 'qpidd' do
  action :stop
end

remote_file "/tmp/IBM_URBANCODE_DEPLOY_WITH_PATTERN.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCD/IBM_URBANCODE_DEPLOY_WITH_PATTERN.zip"
	action :create
end

execute "Unzip IBM_URBANCODE_DEPLOY_WITH_PATTERN.zip" do
  command 'unzip /tmp/IBM_URBANCODE_DEPLOY_WITH_PATTERN.zip -d /tmp/IBM_URBANCODE_DEPLOY_WITH_PATTERN'
  action :run
end

remote_file "/tmp/ibm-ucd-patterns-install-6114.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/UCD/ibm-ucd-patterns-install-6114.zip"
	action :create
end

execute "Unzip ibm-ucd-patterns-install-6114.zip" do
  command "unzip /tmp/ibm-ucd-patterns-install-6114.zip -d /tmp/ibm-ucd-patterns-install-6114"
  action :run
end

#execute 'Install UCDwP' do
#  user 'root'
#  command './install.sh -l -a http://lmb-ucdwp-server:5000/v2.0 -i lmb-ucdwp-server -b 0.0.0.0'
#  cwd '/tmp/IBM_URBANCODE_DEPLOY_WITH_PATTERN/ibm-ucd-patterns-install/engine-install/'
#  action :run
#end

#execute 'Install UCDwP Fix' do
#  user 'root'
#  command './install.sh -l -a http://lmb-ucdwp-server:5000/v2.0 -i lmb-ucdwp-server -b 0.0.0.0'
#  cwd '/tmp/ibm-ucd-patterns-install-6114/ibm-ucd-patterns-install/engine-install/'
#  action :run
#end

#service "openstack-heat-engine" do
#  action :start
#end

#service "openstack-heat-api" do
#  action :start
#end

#service "openstack-heat-api-cfn" do
#  action :start
#end

#service "openstack-heat-api-cloudwatch" do
#  action :start
#end

#service "openstack-keystone" do
#  action :start
#end
