include_recipe "awscli::default"

remote_file "/tmp/aws-java-sdk-1.3.7.jar" do
	source "https://lmbgalaxy.s3.amazonaws.com/AWS/aws-java-sdk-1.3.7.jar"
	action :create_if_missing
end

directory "/root/.aws" do
  action :create
end

cookbook_file "config" do
  path "/root/.aws/config"
  action :create
end

cookbook_file "credentials" do
  path "/root/.aws/credentials"
  action :create
end



