include_recipe "base::ec2" if node.key?("ec2")

limits_config 'system-wide limits' do
  limits [
    { domain: '*', type: 'hard', item: 'nofile', value: 10000 },
    { domain: '*', type: 'soft', item: 'nofile', value: 10000 },
    { domain: '*', type: 'hard', item: 'nproc', value: 10000 },
    { domain: '*', type: 'soft', item: 'nproc', value: 10000 }
  ]
  use_system true
end

reboot "now" do
  action :reboot_now
  reason "Cannot continue Chef run without a reboot."
end