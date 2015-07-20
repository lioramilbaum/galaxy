directory "/etc/chef/ohai/hints/" do
    action :create
    recursive true
end

file "/etc/chef/ohai/hints/ec2.json" do 
    action :create
end