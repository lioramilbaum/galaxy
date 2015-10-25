#
# Cookbook Name:: IBM_Java
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "libarchive::default"

service 'JTS' do
	action :stop
end

remote_file "Download IBM Java" do
    path "#{Chef::Config['file_cache_path']}/#{node['IBM_Java']['zip']}"
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/Java/#{node['IBM_Java']['zip']}"
	action :create
  notifies :run, 'ruby_block[Rename directory]', :immediately
end

ruby_block "Rename directory" do
	block do
		::File.rename("/opt/IBM/JazzTeamServer/server/jre","/opt/IBM/JazzTeamServer/server/jre-Original")
	end
	notifies :extract, 'libarchive_file[unzip IBM Java zip]', :immediately
end

libarchive_file "unzip IBM Java zip" do
  path "#{Chef::Config['file_cache_path']}/#{node['IBM_Java']['zip']}"
  extract_to "/opt/IBM/JazzTeamServer/server/jre"
  action :nothing
end

directory '/opt/IBM/JazzTeamServer/server/tomcat/temp' do
  action :delete
end

directory '/opt/IBM/JazzTeamServer/server/tomcat/work/Catalina/localhost' do
  action :delete
end

service 'JTS' do
	action :start
end