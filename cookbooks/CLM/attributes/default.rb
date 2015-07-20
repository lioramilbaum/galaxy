#set['CLM']['zip'] =
#set['CLM']['fix'] =
#set['CLM']['packages'] =
#set['CLM']['build_zip'] =
#set['CLM']['build_packages'] =
set['CLM']['use_build'] = true
#set['CLM']['rdm_zip'] =
#set['CLM']['rdm_packages'] =
set['CLM']['use_rdm'] = false
set['CLM']['parametersfile'] = "/tmp/CLM.properties"
set['CLM']['activation_key'] = 'dabbad00-8872-36d4-b246-ca785dd63fde'

if attribute?("ec2")
    set['CLM']['server_hostname'] = node['ec2']['public_hostname']
else
    set['CLM']['server_hostname'] = node['hostname']
end