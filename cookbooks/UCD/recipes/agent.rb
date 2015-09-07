include_recipe "libarchive::default"
include_recipe "java7::default"

bash 'download ibm-ucd-agent.zip' do
	code <<-EOH
SERVER_PRIVATE_IP=`grep local-ipv4 /vagrant/ucd_server.txt | cut -d: -f2`
SERVER_PRIVATE_IP=`echo $SERVER_PRIVATE_IP`
scp -i "/home/ubuntu/.ssh/id_rsa.pem" ubuntu@$SERVER_PRIVATE_IP:/opt/ibm-ucd/server/opt/tomcat/webapps/ROOT/tools/ibm-ucd-agent.zip /tmp
	EOH
end

libarchive_file "ibm-ucd-agent.zip" do
  path "/tmp/ibm-ucd-agent.zip"
  extract_to "/tmp/UCD_AGENT"
  action :extract
end

template "/tmp/agent.properties" do
  source "agent.properties.erb"
  variables ({
     :server_hostname => node['UCD']['server_hostname']
  })
  action :create
end

execute 'install-agent-from-file.sh' do
  command "/tmp/UCD_AGENT/ibm-ucd-agent-install/install-agent-from-file.sh /tmp/agent.properties"
  action :run
end

execute 'agent start' do
  user 'root'
  command "/opt/ibm-ucd/agent/bin/agent start"
  action :run
end

execute 'sleep' do
  command "sleep 1m"
  action :run
end

template "/tmp/agent.json" do
  source "agent.json.erb"
  action :create
  notifies :run, 'execute[Configure Agent]', :immediately
end

execute 'Configure Agent' do
  command "curl -s -X PUT -u admin:admin  -d @/tmp/agent.json https://#{node['UCD']['server_hostname']}:8443/cli/systemConfiguration --insecure"
  action :nothing
end

execute 'Configure1 Agent' do
  command "curl -s -X PUT -u admin:admin https://#{node['UCD']['server_hostname']}:8443/cli/teamsecurity/tokens?user=admin&expireDate=12-31-2020-00:24"
  action :run
end