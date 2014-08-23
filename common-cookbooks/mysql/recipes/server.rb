#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

remote_file "/tmp/MySQL-#{node['mysql']['version']}.rpm-bundle.tar" do
  source "#{node['mysql']['remote_uri']}"
end

bash "install_mysql" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    tar xf "MySQL-#{node['mysql']['version']}.rpm-bundle.tar"
  EOH
end

%w{perl libaio}.each do |pkg|
  package pkg do
    action :install
  end
end

%w{MySQL-shared-compat MySQL-shared MySQL-server}.each do |pkg|
  package pkg do
    action :install
    provider Chef::Provider::Package::Rpm
    source "/tmp/#{pkg}-#{node[:mysql][:version]}.rpm"
  end
end

service "mysql" do
  action [:enable, :start]
end

bash "set root password" do
  user "root"
  not_if "mysql -u root -p#{node['mysql']['server_root_password']} -e 'show databases;'"
  code <<-EOL
    export INITIAL_PW=`head -n 1 /root/.mysql_secret | awk '{print $(NF - 0)}'`
    mysql -u root -p${INITIAL_PW} --connect-expired-password -e "SET PASSWORD FOR root@localhost=PASSWORD('#{node['mysql']['server_root_password']}');"
    mysql -u root -p#{node['mysql']['server_root_password']} -e "SET PASSWORD FOR root@'127.0.0.1'=PASSWORD('#{node['mysql']['server_root_password']}');"
    mysql -u root -p#{node['mysql']['server_root_password']} -e "FLUSH PRIVILEGES;"
  EOL
end