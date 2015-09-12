# -*- mode: ruby -*-
# vi: set ft=ruby :
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
  exec "vagrant #{ARGV.join' '}"
end

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	if ARGV[1]=='ubuntu'
		config.vm.box = "Opscode ubuntu-12.04"
		config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box"
	else
		config.vm.box = "Opscode-ubuntu-12.04-Galaxy"
	end
	config.berkshelf.berksfile_path = "Berksfile"
	config.berkshelf.enabled = true
	config.hostmanager.enabled = true
	config.hostmanager.manage_host = true
	config.omnibus.chef_version = :latest
	config.vm.synced_folder '.', '/vagrant', :disabled => false
	
	config.vm.define "db"  do |db|
	
		
		db.vm.provider "virtualbox" do |vb, override|
  			override.vm.hostname = configs["DB_HOSTNAME"]
  			override.vm.network "private_network", ip: configs["DB_IP"]
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vb.memory = 4096
		end
		
		db.vm.provider "aws" do |aws, override|
		
			override.vm.box		= "dummy"
			override.vm.box_url	= "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
			override.vm.synced_folder "keys", "/vagrant/keys", type: "rsync"
			
			aws.access_key_id		= ENV['AWS_ACCESS_KEY']
			aws.secret_access_key	= ENV['AWS_SECRET_KEY']
			aws.keypair_name		= "id_rsa"   

			aws.region				= "eu-west-1"
    		aws.ami					= "ami-60a10117"
   			aws.instance_type		= "m3.xlarge"
    		aws.security_groups		= [ 'sg-77371612' ]
    		aws.subnet_id			= "subnet-7cf03b25"
    		aws.elastic_ip			= "true"
    		aws.block_device_mapping	= [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 100 }]

    		override.ssh.username	= "ubuntu"
    		override.ssh.insert_key = "true"
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
    		
    	end
	
		db.vm.provider :vsphere do |vsphere, override|

			override.vm.box = 'vsphere'
			override.vm.box_url = 'https://vagrantcloud.com/ssx/boxes/vsphere-dummy/versions/0.0.1/providers/vsphere.box'
			override.vm.synced_folder "keys", "/vagrant/keys", type: "rsync"

			vsphere.host = 'vcenterlan.redbend.com'                           
			vsphere.compute_resource_name = 'ilvmdr.redbend.com'           
			vsphere.resource_pool_name = 'linux'                       
			vsphere.template_name = 'ubuntu'     
			vsphere.name = 'rb-db-server'                                       
			vsphere.user = 'root'                                   
			vsphere.password = 'scrjze12#'                           
			vsphere.insecure = true 
			vsphere.memory_mb = 8192
			vsphere.cpu_count = 2
			
    	end
    	
    	db.vm.provision :chef_zero do |chef|
			chef.cookbooks_path = ["./cookbooks/"]
			chef.add_recipe "DB2::default"
		end
		db.vm.provision "shell", path: "components/DB/DB2/deploy-db2.sh"
		
	end
	
	config.vm.define "ucd_server" do |ucd_server|
			
		ucd_server.vm.provider "virtualbox" do |vb , override|
			override.vm.hostname = configs["UCD_HOSTNAME"]
  			override.vm.network "private_network", ip: configs["UCD_IP"]
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vb.memory = 2048
		end
		
		ucd_server.vm.synced_folder ".", "/vagrant", type: "rsync"
			
		ucd_server.vm.provider "aws" do |aws, override|
			override.vm.box		= "dummy"
			override.vm.box_url	= "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
			
			aws.access_key_id		= ENV['AWS_ACCESS_KEY']
			aws.secret_access_key	= ENV['AWS_SECRET_KEY']
			aws.keypair_name		= "id_rsa"   

			aws.region				= "eu-west-1"
    		aws.ami					= "ami-60a10117"
   			aws.instance_type		= "t2.small"
    		aws.security_groups		= [ 'sg-66dc4703' ]
    		aws.subnet_id			= "subnet-7cf03b25"
    		aws.elastic_ip			= "true"
     		
    		override.ssh.username	= "ubuntu"
    		override.ssh.insert_key = "true"
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"   		
    		aws.tags = {
    		    	'Name' => 'ucd_server'
    		}
    		
    	end
		
		config.vm.provision :shell, :path => "scripts/bootstrap.sh"
    	
 		ucd_server.vm.provision :chef_zero do |chef|    
			chef.environments_path = ["./environments/"]
			chef.environment = 'curr'
			chef.cookbooks_path = ["./cookbooks/"]
			chef.add_recipe "UCD::server"
			chef.add_recipe "UCD::JPetStore"
		end
		
	end
	
	config.vm.define "ucd_agent1" do |ucd_agent1|

		ucd_agent1.vm.provider "virtualbox" do |vb, override|
  			override.vm.hostname = configs["AGENT1_HOSTNAME"]
  			override.vm.network "private_network", ip: configs["AGENT1_IP"]
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vb.memory = 1024
		end
		
		ucd_agent1.vm.provider "aws" do |aws, override|
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
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
    		
    		aws.tags = {
    		    	'Name' => 'ucd_agent1'
    		}
    	end
    	
		config.vm.provision :host_shell do |host_shell|
			host_shell.inline = "cmd /c metadata.bat" 
		end
		
		config.vm.provision "file", source: "ucd_server.txt", destination: "/vagrant/ucd_server.txt"
		config.vm.provision "file", source: "C:\\Users\\Liora\\.ssh\\id_rsa.pem", destination: "/home/ubuntu/.ssh/id_rsa.pem"
		
    	config.vm.provision :shell, :path => "scripts/bootstrap.sh"
    	
		ucd_agent1.vm.provision :chef_zero do |chef|  	
			chef.environments_path = ["./environments/"]
			chef.environment = 'curr'
			chef.cookbooks_path = ["./cookbooks/"]
			chef.add_recipe "UCD::agent"
			chef.add_recipe "UCD::JPetStore"
		end
		
	end
	
	config.vm.define "ucd_agent2" do |ucd_agent2|

		ucd_agent2.vm.provider "virtualbox" do |vb, override|
  			override.vm.hostname = configs["AGENT2_HOSTNAME"]
  			override.vm.network "private_network", ip: configs["AGENT2_IP"]
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vb.memory = 1024
		end
		
		ucd_agent2.vm.provider "aws" do |aws, override|
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
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
    		aws.tags = {
    		    	'Name' => 'ucd_agent2'
    		}
    	end
    	
    	config.vm.provision :shell, :path => "scripts/bootstrap.sh"
    	
    	ucd_agent2.vm.provision :chef_zero do |chef|    
			chef.environments_path = ["./environments/"]
			chef.environment = 'curr'
			chef.cookbooks_path = ["./cookbooks/"]
			chef.add_recipe "UCD::agent"
		end
		
	end
		
	config.vm.define "rlia" do |rlia|

		rlia.vm.provider "virtualbox" do |vb, override|  			
			override.vm.hostname = configs["RLIA_HOSTNAME"]
  			override.vm.network "private_network", ip: configs["RLIA_IP"]
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vb.memory = 4096
		end
		
		rlia.vm.provider "aws" do |aws, override|
			override.vm.box		= "dummy"
			override.vm.box_url	= "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
			override.vm.synced_folder "keys", "/vagrant/keys", type: "rsync"
			
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
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
    		
    	end
    	
    	rlia.vm.provision :chef_zero do |chef|
			chef.cookbooks_path = ["./cookbooks/"]
			chef.add_recipe "RLIA::default"
		end
	end	
		
	config.vm.define "ansible" do |ansible|

		ansible.vm.provider "virtualbox" do |vb, override|  			
			override.vm.hostname = configs["ANSIBLE_HOSTNAME"]
  			override.vm.network "private_network", ip: configs["ANSIBLE_IP"]
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vb.memory = 4096
		end
    	
    	ansible.vm.provision :chef_zero do |chef|
			chef.cookbooks_path = ["./cookbooks/"]
			chef.add_recipe "ANSIBLE::default"
		end
	end
	
	config.vm.define "ci" do |ci|
		
		ci.vm.provider "virtualbox" do |vb, override|			
			override.vm.hostname = configs["CI_HOSTNAME"]
			override.vm.network "private_network", ip: configs["CI_IP"]
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vb.memory = 1024
		end
		
		ci.vm.provider "aws" do |aws, override|
			override.vm.box		= "dummy"
			override.vm.box_url	= "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
			
			aws.access_key_id		= ENV['AWS_ACCESS_KEY']
			aws.secret_access_key	= ENV['AWS_SECRET_KEY']
			aws.keypair_name		= "id_rsa"   

			aws.region				= "eu-west-1"
    		aws.ami					= "ami-60a10117"
   			aws.instance_type		= "t2.small"
    		aws.security_groups		= [ 'sg-66dc4703' ]
    		aws.subnet_id			= "subnet-7cf03b25"
    		aws.elastic_ip			= "true"

    		override.ssh.username	= "ubuntu"
    		override.ssh.insert_key = "true"
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
    		
    	end
    	
		ci.vm.provision :chef_zero do |chef|		
			chef.json = {
				'CLM' => {
					'server_hostname' => configs["CLM_HOSTNAME"]
				}
			}
			chef.cookbooks_path = ["./cookbooks/"]
			chef.environments_path = ["./environments/"]
			chef.environment = 'prev'
			chef.add_recipe "CLM::build"
		end
		
#		ci.vm.provision "shell", path: "components/CI/apache-maven/deploy-maven.sh"
#		ci.vm.provision "shell", path: "components/CI/apache-maven/sample/JPetStore/deploy-JPetStore-sample.sh"
#		ci.vm.provision "shell", path: "components/REPO/artifactory/deploy-artifactory.sh"
#		ci.vm.provision "shell", path: "components/REPO/artifactory/sample/JPetStore/deploy-JPetStore-sample.sh"
#		ci.vm.provision "shell", path: "components/CI/Jenkins/deploy-jenkins.sh"
#		ci.vm.provision "shell", path: "components/CI/Bamboo/deploy-bamboo.sh"
#		ci.vm.provision "shell", path: "components/CI/Jenkins-RTC-Build/deploy-jenkins-rtc-build.sh"
#		ci.vm.provision "shell", path: "components/IBM/deploy-rlks.sh"
	end	

	config.vm.define "git" do |git|
		git.vm.hostname = configs["GIT_HOSTNAME"]
		git.vm.network "private_network", ip: configs["GIT_IP"]
		
		git.vm.provider "virtualbox" do |vbox, override|
			override.vm.box		= "precise64a"
			
			vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vbox.memory = 1024
		end
		
		git.vm.provider "aws" do |aws, override|
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
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
    		
    	end
		
		git.vm.provision "shell", path: "components/SCM/git/deploy-git.sh"
		git.vm.provision "shell", path: "components/SCM/git/deploy-sample-git-repo.sh"
	end
	
	config.vm.define "github" do |github|
		github.vm.hostname = configs["GITHUB_HOSTNAME"]
		
		github.vm.provider "virtualbox" do |vb|
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vb.memory = 8192
		end
		
		github.vm.provider "aws" do |aws, override|
			override.vm.box		= "dummy"
			override.vm.box_url	= "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
			
			aws.access_key_id		= ENV['AWS_ACCESS_KEY']
			aws.secret_access_key	= ENV['AWS_SECRET_KEY']
			aws.keypair_name		= "id_rsa"   

			aws.region				= "eu-west-1"
    		aws.ami					= "ami-c3bd3eb4"
   			aws.instance_type		= "t2.small"
    		aws.security_groups		= [ 'sg-66dc4703' ]
    		aws.subnet_id			= "subnet-7cf03b25"
    		aws.elastic_ip			= "true"

    		override.ssh.username	= "ubuntu"
    		override.ssh.insert_key = "true"
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
    		
    	end
    end
    	
    config.vm.define "jira" do |jira|
  		jira.vm.hostname = configs["JIRA_HOSTNAME"]
  		jira.vm.network "private_network", ip: configs["JIRA_IP"]

		jira.vm.provider "virtualbox" do |vb|
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vb.memory = 2048
		end
		
		jira.vm.provider "aws" do |aws, override|
			override.vm.box		= "dummy"
			override.vm.box_url	= "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
			override.vm.synced_folder ".", "/vagrant", type: "rsync"
			
			aws.access_key_id		= ENV['AWS_ACCESS_KEY']
			aws.secret_access_key	= ENV['AWS_SECRET_KEY']
			aws.keypair_name		= "id_rsa"   

			aws.region				= "eu-west-1"
    		aws.ami					= "ami-60a10117"
   			aws.instance_type		= "t2.small"
    		aws.security_groups		= [ 'sg-66dc4703' ]
    		aws.subnet_id			= "subnet-7cf03b25"
    		aws.elastic_ip			= "true"

    		override.ssh.username	= "ubuntu"
    		override.ssh.insert_key = "true"
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
    		
    	end
    	
		jira.vm.provision :chef_zero do |chef|
			chef.cookbooks_path = ["./cookbooks/"]
			chef.add_recipe "jira6.4::default"
		end
	end
	
	config.vm.define "rrdi"  do |rrdi|
  		rrdi.vm.hostname = configs["RRDI_HOSTNAME"]
  		rrdi.vm.network "private_network", ip: configs["RRDI_IP"] 
		
		rrdi.vm.provider "virtualbox" do |vb|
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vb.memory = 8192
		end
		
		rrdi.vm.provider "aws" do |aws, override|
			override.vm.box		= "dummy"
			override.vm.box_url	= "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
			override.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ["*.zip ", "*.gz", ".*/"]
			
			aws.access_key_id		= ENV['AWS_ACCESS_KEY']
			aws.secret_access_key	= ENV['AWS_SECRET_KEY']
			aws.keypair_name		= "id_rsa"   

			aws.region				= "eu-west-1"
    		aws.ami					= "ami-810d79bb"
   			aws.instance_type		= "t2.micro"
    		aws.security_groups		= [ 'sg-66dc4703' ]
    		aws.subnet_id			= "subnet-7cf03b25"
    		aws.elastic_ip			= "true"
    		aws.block_device_mapping	= [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 100 }]

    		override.ssh.username	= "ubuntu"
    		override.ssh.insert_key = "true"
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
    		
    	end
    	

		
		rrdi.vm.provision :chef_zero do |chef|
			chef.cookbooks_path = ["./cookbooks/"]
			chef.add_recipe "clm::init"
		end
		rrdi.vm.provision :reload
		rrdi.vm.provision :chef_zero do |chef|
			chef.cookbooks_path = ["./cookbooks/"]
			chef.add_recipe "im::default"
		end
		rrdi.vm.provision "shell", path: "components/IBM/deploy-was.sh"
		rrdi.vm.provision "shell", path: "components/REPORTING/deploy-rrdi.sh"
	end
	
	config.vm.define "stash" do |stash|
		stash.vm.hostname = configs["STASH_HOSTNAME"]
		stash.vm.network "private_network", ip: configs["STASH_IP"]
		
		stash.vm.provider "virtualbox" do |vbox, override|
			override.vm.box		= "ubuntu/trusty64"
			override.vm.box_url	= "https://vagrantcloud.com/ubuntu/boxes/trusty64"
			
			vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vbox.memory = 1024
		end
		
		stash.vm.provider "aws" do |aws, override|
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
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
    		
    	end
		
		stash.vm.provision "shell", path: "components/SCM/git/deploy-git.sh"
		stash.vm.provision "shell", path: "components/DB/PostgreSQL/deploy-postgresql.sh"
		stash.vm.provision "shell", path: "components/SCM/Stash/deploy-stash.sh"
	end	
	
	config.vm.define "ucr" do |ucr|
  		ucr.vm.hostname = configs["UCR_HOSTNAME"]
  		ucr.vm.network "private_network", ip: configs["UCR_IP"]

		ucr.vm.provider "virtualbox" do |vb|
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			vb.memory = 1024
		end
		
		ucr.vm.provider "aws" do |aws, override|
			override.vm.box		= "dummy"
			override.vm.box_url	= "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
			override.vm.synced_folder ".", "/vagrant", type: "rsync"
			
			aws.access_key_id		= ENV['AWS_ACCESS_KEY']
			aws.secret_access_key	= ENV['AWS_SECRET_KEY']
			aws.keypair_name		= "id_rsa"   

			aws.region				= "eu-west-1"
    		aws.ami					= "ami-60a10117"
   			aws.instance_type		= "t2.small"
    		aws.security_groups		= [ 'sg-66dc4703' ]
    		aws.subnet_id			= "subnet-7cf03b25"
    		aws.elastic_ip			= "true"

    		override.ssh.username	= "ubuntu"
    		override.ssh.insert_key = "true"
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
    		
    	end

	end
	
	config.vm.define "clm" do |clm|
	
		clm.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".*/", "packer_cache/"]
			
		clm.vm.provider "aws" do |aws, override|
			override.vm.box		= "liora/clm"
			aws.region			= "eu-west-1"
			aws.ami				= "ami-858ba8f2"			
			aws.keypair_name	= "id_rsa"
   			aws.instance_type	= "m3.xlarge"
    		aws.security_groups	= [ 'sg-66dc4703' ]
    		aws.subnet_id		= "subnet-7cf03b25"
    		aws.elastic_ip		= "true"
    		aws.block_device_mapping	= [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 100 }]

    		override.ssh.username	= "ubuntu"
    		override.ssh.insert_key = "true"
    		override.ssh.private_key_path = "C:\\Users\\Liora\\.ssh\\id_rsa.pem"
		end	
		
		config.vm.provision :shell, :path => "scripts/bootstrap.sh"
		
		clm.vm.provision :chef_zero do |chef|
			chef.cookbooks_path = ["./cookbooks/"]
			chef.environments_path = ["./environments/"]
			chef.environment = 'curr'
			chef.add_recipe "CLM::setup"
		end
	end
	
	config.push.define "atlas" do |push|
		push.app = "liora/clm"
		push.vcs = true
	end
	
end