require 'yaml'

current_dir    = File.dirname(File.expand_path(__FILE__))
configs        = YAML.load_file("#{current_dir}/conf/Galaxy.yaml")

# Check for missing plugins
required_plugins = %w( vagrant-aws vagrant-berkshelf vagrant-hostmanager vagrant-omnibus vagrant-reload vagrant-share vagrant-vbguest vagrant-host-shell)
plugin_installed = false
required_plugins.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    system "vagrant plugin install #{plugin}"
    plugin_installed = true
  end
end

# If new plugins installed, restart Vagrant process
if plugin_installed === true
  exec "/usr/local/bin/vagrant #{ARGV.join' '}"
end

hosts = [
	{
		name: "ucd_server",
		ami: "ami-60a10117",
		instance_type: "t2.small",
		aws_tag: "ucd_server",
		chef_role: "ucd_server"
	},
	{
		name: "ucd_agent",
		ami: "ami-60a10117",
		instance_type: "t2.micro",
		aws_tag: "ucd_agent",
		chef_role: "ucd_agent"
	},
	{
		name: "appscan",
		ami: "ami-60a10117",
		instance_type: "t2.micro",
		aws_tag: "AppScan",
		chef_role: "appscan"
	},
]

Vagrant.configure("2") do |config|

	config.berkshelf.berksfile_path = "Berksfile"
	config.berkshelf.enabled = true
	config.hostmanager.enabled = true
	config.hostmanager.manage_host = true
	config.omnibus.chef_version = :latest
	config.vm.synced_folder '.', '/vagrant', type: "rsync", disabled: false
	
	hosts.each do |host|
	
		config.vm.define host[:name] do |node|
		
			node.vm.provider "aws" do |aws, override|
				override.vm.box		= "dummy"
				override.vm.box_url	= "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
			
				aws.access_key_id		= ENV['AWS_ACCESS_KEY']
				aws.secret_access_key	= ENV['AWS_SECRET_KEY']
				aws.keypair_name		= "id_rsa"   

				aws.region				= "eu-west-1"
    			aws.ami					= host[:ami]
   				aws.instance_type		= host[:instance_type]
    			aws.security_groups		= [ 'sg-66dc4703' ]
    			aws.subnet_id			= "subnet-7cf03b25"
    			aws.elastic_ip			= "true"
     		
    			override.ssh.username	= "ubuntu"
    			override.ssh.insert_key = "true"
    			override.ssh.private_key_path = "/Users/liora/.ssh/id_rsa.pem"   		
    			aws.tags = {
    		    		'Name' => host[:aws_tag]
    			}
    		
    		end
		
			node.vm.provision :shell, :path => "scripts/bootstrap.sh"
    	
 			node.vm.provision :chef_zero do |chef|    
				chef.environments_path = ["./environments/"]
				chef.environment = 'curr'
				chef.cookbooks_path = ["./cookbooks/"]
				chef.roles_path = ["./roles/"]
				chef.add_role host[:chef_role]
			end
			
		end
		
	end
	
	config.vm.define "ucd_agent" do |ucd_agent|
		
		ucd_agent.vm.provider "aws" do |aws, override|
			override.vm.box		= "dummy"
			override.vm.box_url	= "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
			
			aws.access_key_id		= ENV['AWS_ACCESS_KEY']
			aws.secret_access_key	= ENV['AWS_SECRET_KEY']
			aws.keypair_name		= "id_rsa"   

			aws.region				= "eu-west-1"
    		aws.ami					= "ami-60a10117"
   			aws.instance_type		= "t2.micro"
    		aws.security_groups		= [ 'sg-66dc4703' ]
    		aws.subnet_id			= "subnet-7cf03b25"
    		aws.elastic_ip			= "true"

    		override.ssh.username	= "ubuntu"
    		override.ssh.insert_key = "true"
    		override.ssh.private_key_path = "/Users/liora/.ssh/id_rsa.pem"
    		
    		aws.tags = {
    		    	'Name' => 'ucd_agent1'
    		}
    	end
    	
		config.vm.provision :host_shell do |host_shell|
			host_shell.inline = "cmd /c metadata.bat" 
		end
		
		config.vm.provision "file", source: "ucd_server.txt", destination: "/vagrant/ucd_server.txt"
		config.vm.provision "file", source: "/Users/liora/.ssh/id_rsa.pem", destination: "/home/ubuntu/.ssh/id_rsa.pem"
		
    	config.vm.provision :shell, :path => "scripts/bootstrap.sh"
    	
		ucd_agent.vm.provision :chef_zero do |chef|  	
			chef.environments_path = ["./environments/"]
			chef.environment = 'curr'
			chef.cookbooks_path = ["./cookbooks/"]
			chef.roles_path = ["./roles/"]
			chef.add_role "ucd_agent"
		end
		
	end
	
	config.push.define "atlas" do |push|
		push.token = "DCn3cXyWFXN6zwAUcX5iRsyyeqQPn7mARsxxsV8ys5tdexprXyZgUaY6JNRG5mQFu94" 
		push.app = "liora/clm"
		push.vcs = true
	end
	
end