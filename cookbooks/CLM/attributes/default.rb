default['CLM']['zip'] = nil
default['CLM']['fix'] = nil
default['CLM']['packages'] = nil
default['CLM']['fix_package'] = nil
default['CLM']['build_zip'] = nil
default['CLM']['build_packages'] = nil
default['CLM']['use_build'] = true
default['CLM']['rdm_zip'] = nil
default['CLM']['rdm_packages'] = nil
default['CLM']['use_rdm'] = false
default['CLM']['parametersfile'] = "/tmp/CLM.properties"
default['CLM']['activation_key'] = 'dabbad00-8872-36d4-b246-ca785dd63fde'

if node.key?("ec2")
    default['CLM']['server_hostname'] = node['ec2']['public_hostname']
else
    default['CLM']['server_hostname'] = node['hostname']
end