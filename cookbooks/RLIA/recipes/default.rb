include_recipe "libarchive::default"

remote_file "/vagrant/install/IBM-RLIA-TasktopEdition-1.1.3-TRIAL.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/IBM/RLIA/IBM-RLIA-TasktopEdition-1.1.3-TRIAL.zip"
	action :create_if_missing
end

libarchive_file "IBM-RLIA-TasktopEdition-1.1.3-TRIAL.zip" do
  path "/vagrant/install/IBM-RLIA-TasktopEdition-1.1.3-TRIAL.zip"
  extract_to "/tmp/RLIA"
  action :extract
end

#execute 'install' do
#  command 'sudo /tmp/RLIA/IBM-RLIA-TasktopEdition-lin-1.1.3.20141021-1720-TRIAL.bin'
#  action :run
#end