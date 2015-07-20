remote_file "/tmp/artifacts.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/samples/artifacts.zip"
	action :create_if_missing
end