bash 'env_locale' do	
	user 'root'
	code <<-EOF
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales
EOF
	action :run
end

bash 'configure db' do
	user 'postgres'
  code <<-EOF
psql <<SQL
CREATE DATABASE ibm_ucd;
CREATE USER ibm_ucd WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE ibm_ucd TO ibm_ucd;
commit;
SQL
EOF
	action :run
end

remote_file "#{Chef::Config['file_cache_path']}/postgresql-9.4-1205.jdbc41.jar" do
	source "https://jdbc.postgresql.org/download/postgresql-9.4-1205.jdbc41.jar"
	action :create
end

