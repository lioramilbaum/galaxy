include_recipe "python::default"


python_pip "ansible" do
  action :install
end

