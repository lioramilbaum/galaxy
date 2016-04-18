ruby_block 'hostname' do
	block do
		if node['ec2'] == nil
			node.default['CLM']['server_hostname'] = node['hostname']
		else
			node.default['CLM']['server_hostname'] = node['ec2']['public_hostname']
		end
	end
end

template "Setup Properties File RDM False" do
	path "#{Chef::Config['file_cache_path']}/CLM.properties"
	source 'CLM.properties.erb'
	variables (
  		lazy {
  			{
  				:use_rdm => 'false',
				:server_hostname => "#{node['CLM']['server_hostname']}"
			}
		}
	)
	action :create
	notifies :run, 'execute[CLM Setup without RDM]', :immediately
end

execute 'CLM Setup without RDM' do
	user 'root'
	cwd "/opt/IBM/JazzTeamServer/server"
	command "./repotools-jts.sh -setup includeLifecycleProjectStep=true parametersfile=#{Chef::Config['file_cache_path']}/CLM.properties"
	action :nothing
end

template "Setup Properties File RDM True" do
	path "#{Chef::Config['file_cache_path']}/CLM1.properties"
	source 'CLM.properties.erb'
	variables (
  		lazy {
  			{
  				:use_rdm => 'true',
				:server_hostname => node['ec2']['public_hostname']
			}
		}
	)
	action :create
	notifies :run, 'execute[CLM Setup with RDM]', :immediately
end

execute 'CLM Setup with RDM' do
	user 'root'
	cwd "/opt/IBM/JazzTeamServer/server"
	command "./repotools-jts.sh -setup parametersfile=#{Chef::Config['file_cache_path']}/CLM1.properties adminUserId=liora adminPassword=liora"
	action :nothing
end

execute 'Assign build license' do
  user 'root'
  cwd "/opt/IBM/JazzTeamServer/server"
  command "./repotools-jts.sh -createUser adminUserId=liora adminPassword=liora userId=build licenseId='com.ibm.team.rtc.buildsystem'"
  action :nothing
  ignore_failure false
  returns [0,22]
end
