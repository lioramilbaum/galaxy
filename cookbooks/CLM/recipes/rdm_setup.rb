template "Setup Properties File for RDM" do
	path "#{Chef::Config['file_cache_path']}/RDM.properties"
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
	notifies :run, 'execute[CLM Setup for RDM]', :immediately
end

execute 'CLM Setup for RDM' do
	user 'root'
	cwd "/opt/IBM/JazzTeamServer/server"
	command "./repotools-jts.sh -setup adminUserId=liora adminPassword=liora includeLifecycleProjectStep=false parametersfile=#{Chef::Config['file_cache_path']}/RDM.properties"
	action :nothing
end