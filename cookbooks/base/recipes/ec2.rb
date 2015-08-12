directory "/etc/chef/ohai/hints/" do
    user root
    action :create
    recursive true
end

file "/etc/chef/ohai/hints/ec2.json" do
    user root
    action :create
end