#
# Cookbook Name:: chef_workstation
# Recipe:: default
#
# Copyright 2015, L.M.B.-Consulting Ltd.
#
# All rights reserved - Do Not Redistribute
#

remote_file 'chefdk_0.7.0-1_amd64.deb' do
	path "#{Chef::Config[:file_cache_path]}/chefdk_0.7.0-1_amd64.deb"
	source "https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.7.0-1_amd64.deb"
	action :create
end

dpkg_package 'chefdk_0.7.0-1_amd64.deb' do
	source "#{Chef::Config[:file_cache_path]}/chefdk_0.7.0-1_amd64.deb"
	action :install
end

#chef_gem 'knife-ec2' do
#	action :install
#end

execute 'install knife-ec2' do
  command "chef gem install knife-ec2"
  action :run
end