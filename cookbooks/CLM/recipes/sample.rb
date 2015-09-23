cookbook_file "users.csv" do
    path "#{Chef::Config['file_cache_path']}/users.csv"
    action :create
    notifies :run, 'execute[sample users]', :immediately
end

execute 'sample users' do
  user 'root'
  cwd '/opt/IBM/JazzTeamServer/server'
  command "./repotools-jts.sh -importUsers fromFile=#{Chef::Config['file_cache_path']}/users.csv adminUserId=liora adminPassword=liora repositoryURL=https://#{node['CLM']['server_hostname']}:9443/jts"
  action :nothing
end