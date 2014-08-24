#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "mysql::client"

package "libaio" do
  action :install
end

%w{MySQL-shared-compat MySQL-shared MySQL-server}.each do |pkg|
  package pkg do
    action :install
    provider Chef::Provider::Package::Rpm
    source "/tmp/#{pkg}-#{node[:mysql][:version]}.rpm"
  end
end

package "innotop" do
  action :install
end

# auto setting config
node.set[:mysql][:server][:thread_concurrency] = node[:cpu][:total] * 2
node.set[:mysql][:server][:innodb_thread_concurrency] = node[:cpu][:total] * 2
node.set[:mysql][:server][:innodb_read_io_threads] = node[:cpu][:total]
node.set[:mysql][:server][:innodb_write_io_threads] = node[:cpu][:total]
# key_buffer_size autoset 30% memory
key_buffer_size = (node[:memory][:total].to_s.delete('kB').to_i * 0.3 / 1024).round(0)
node.set[:mysql][:server][:key_buffer_size] = "#{key_buffer_size}M"
# buffer_pool_size autoset 70% memory
buffer_pool_size = (node[:memory][:total].to_s.delete('kB').to_i * 0.7 / 1024).round(0)
node.set[:mysql][:server][:innodb_buffer_pool_size] = "#{buffer_pool_size}M"

template "/etc/my.cnf" do
  source "my.cnf.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create_if_missing
end

service "mysql" do
  action [:enable, :start]
end

server_root_password = node['mysql']['server_root_password']
bash "set root password" do
  user "root"
  not_if "mysql -u root -p#{server_root_password} -e 'show databases;'"
  code <<-EOL
    export INITIAL_PW=`head -n 1 /root/.mysql_secret | awk '{print $(NF - 0)}'`
    mysql -u root -p${INITIAL_PW} --connect-expired-password -e "SET PASSWORD FOR root@localhost=PASSWORD('#{server_root_password}');"
    mysql -u root -p#{server_root_password} -e "SET PASSWORD FOR root@'127.0.0.1'=PASSWORD('#{server_root_password}');"
    mysql -u root -p#{server_root_password} -e "FLUSH PRIVILEGES;"
  EOL
end