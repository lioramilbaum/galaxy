include_recipe "base::ec2" if node.key?("ec2")

set_limit '*' do
  type 'hard'
  item 'nofile'
  value 10000
  use_system true
end

set_limit '*' do
  type 'soft'
  item 'nofile'
  value 10000
  use_system true
end

set_limit '*' do
  type 'hard'
  item 'nproc'
  value 10000
  use_system true
end

set_limit '*' do
  type 'soft'
  item 'nproc'
  value 10000
  use_system true
end