include_recipe "base::default" if node.key?("ec2")

remote_file "/vagrant/install/DB2_10.5.0.3_limited_Lnx_x86-64.tar.gz" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/DB2/DB2_10.5.0.3_limited_Lnx_x86-64.tar.gz"
	action :create_if_missing
end