# See https://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "liora"
client_key               "#{current_dir}/liora.pem"
validation_client_name   "lmb-validator"
validation_key           "#{current_dir}/lmb-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/lmb"
cookbook_path            ["#{current_dir}/../cookbooks"]
role_path				 ["#{current_dir}/../roles"]

knife[:aws_access_key_id] = ENV['AWS_ACCESS_KEY']
knife[:aws_secret_access_key] = ENV['AWS_SECRET_KEY']
knife[:aws_ssh_key_id] = "id_rsa"
knife[:flavor] = 'm3.xlarge'
knife[:image] = 'ami-2da5875a'
knife[:ssh_user] = 'ubuntu'
knife[:run_list] = [ 'role[clm]' ]
knife[:region] = 'eu-west-1'
knife[:environment] = 'curr'
#knife[:subnet] = 'subnet-7cf03b25'
knife[:associate_public_ip] = 'true'
