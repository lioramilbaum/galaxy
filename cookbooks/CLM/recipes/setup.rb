template "Setup Properties File" do
	path "#{Chef::Config['file_cache_path']}/#{node['CLM'][:parametersfile]}"
	source 'CLM.properties.erb'
	variables (
  		lazy {
  			{
  				:use_rdm => node['CLM']['use_rdm'],
				:server_hostname => node['ec2']['public_hostname']
			}
		}
	)
	action :create
	notifies :run, 'execute[CLM Setup]', :immediately
end

execute 'CLM Setup' do
	user 'root'
	cwd "/opt/IBM/JazzTeamServer/server"
	command "./repotools-jts.sh -setup includeLifecycleProjectStep=true parametersfile=#{Chef::Config['file_cache_path']}/#{node['CLM'][:parametersfile]}"
	action :nothing
	ignore_failure true
end

=begin
execute 'CLM Setup Retry' do
	user 'root'
	cwd "/opt/IBM/JazzTeamServer/server"
	command "./repotools-jts.sh -setup adminUserId=liora adminPassword=liora includeLifecycleProjectStep=true parametersfile=#{Chef::Config['file_cache_path']}/#{node['CLM'][:parametersfile]}"
	action :run
	ignore_failure false
	not_if 'execute[CLM Setup]'
end
=end
