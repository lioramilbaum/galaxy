directory "/etc/chef/ohai/hints/" do
    owner 'root'
    action :create
    recursive true
end

file "/etc/chef/ohai/hints/ec2.json" do
    owner 'root'
    action :create
end