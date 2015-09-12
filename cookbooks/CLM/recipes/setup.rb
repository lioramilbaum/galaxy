=begin

template "Setup JTS.conf" do
  path "/etc/init/JTS.conf"
  source 'JTS.conf.erb'
  action :create
end

service 'JTS' do
	provider Chef::Provider::Service::Upstart
	supports :start => true, :stop => true
	action [ :enable, :start ]
end

=end

execute 'xvfb' do
	user 'root'
	command "Xvfb :1 -screen 0 800x600x24&"
	action :run
    notifies :run, 'execute[starting JTS Server]', :immediately
end

execute 'starting JTS Server' do
  user 'root'
  environment "DISPLAY" => "localhost:1.0"
  command "/opt/IBM/JazzTeamServer/server/server.startup"
  action :nothing
  notifies :run, 'execute[sleep 3m]', :immediately
end

execute 'sleep 3m' do
  command "sleep 3m"
  action :nothing
end

template "Setup Properties File" do
	path "#{node['CLM'][:parametersfile]}"
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
  command "./repotools-jts.sh -setup includeLifecycleProjectStep=true parametersfile=#{node['CLM'][:parametersfile]}"
  action :nothing
  ignore_failure false
  notifies :run, 'execute[Assign build license]', :immediately
end

execute 'Assign build license' do
  user 'root'
  cwd "/opt/IBM/JazzTeamServer/server"
  command "./repotools-jts.sh -createUser adminUserId=liora adminPassword=liora userId=build licenseId='com.ibm.team.rtc.buildsystem'"
  action :nothing
  ignore_failure false
  returns [0,22]
end
