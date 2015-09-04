remote_file "/tmp/artifacts.zip" do
	source "https://lmbgalaxy.s3.amazonaws.com/samples/artifacts.zip"
	action :create_if_missing
end

bash 'deploy' do
  code <<-EOH
echo "==> ${projectName}: Create Application"
APP="Pet Grooming Reservations"
sudo cp /vagrant/components/DEPLOYER/UCD/server/sample/Pet/app.json /tmp
sudo sed -i "s/APP/$APP/g" /tmp/app.json
curl -s -u admin:admin https://#{node['ec2']['public_hostname']}:8443/cli/application/create -X PUT -d @/tmp/app.json --insecure

echo "==> ${projectName}: Create Application Environment"
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure

APP="Pet Transport"	
sudo cp /vagrant/components/DEPLOYER/UCD/server/sample/Pet/app.json /tmp
sudo sed -i "s/APP/$APP/g" /tmp/app.json
curl -s -u admin:admin https://#{node['ec2']['public_hostname']}:8443/cli/application/create -X PUT -d @/tmp/app.json --insecure
echo "==> ${projectName}: Create Application Environment"
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure
	
APP="Pet Breeder Site"	
sudo cp /vagrant/components/DEPLOYER/UCD/server/sample/Pet/app.json /tmp
sudo sed -i "s/APP/$APP/g" /tmp/app.json
curl -s -u admin:admin https://#{node['ec2']['public_hostname']}:8443/cli/application/create -X PUT -d @/tmp/app.json --insecure

echo "==> ${projectName}: Create Application Environment"
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure
	
APP="Pet Sourcing"	
sudo cp /vagrant/components/DEPLOYER/UCD/server/sample/Pet/app.json /tmp
sudo sed -i "s/APP/$APP/g" /tmp/app.json
curl -s -u admin:admin https://#{node['ec2']['public_hostname']}:8443/cli/application/create -X PUT -d @/tmp/app.json --insecure

echo "==> ${projectName}: Create Application Environment"
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=DEV-1&color=#D9182D" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=CERT-1&color=#DD731C" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=QA-1&color=#FFCF01" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PT-1&color=#17AF4B" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-1&color=#007670" --insecure
curl -s -X PUT -u admin:admin  "https://#{node['ec2']['public_hostname']}:8443/cli/environment/createEnvironment?application=$APP&name=PROD-TX&color=#00B2EF" --insecure
  EOH
end