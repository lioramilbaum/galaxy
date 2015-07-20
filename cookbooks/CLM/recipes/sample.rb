cookbook_file "users.csv" do
    path "/tmp/users.csv"
    action :create
    notifies :run, 'execute[sample users]', :immediately
end

execute 'sample users' do
  user 'root'
  cwd '/opt/IBM/JazzTeamServer/server'
  command "./repotools-jts.sh -importUsers fromFile=/tmp/users.csv adminUserId=liora adminPassword=liora repositoryURL=https://#{node['CLM']['server_hostname']}:9443/jts"
  action :nothing
end