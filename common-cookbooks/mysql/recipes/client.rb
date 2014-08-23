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

package "perl" do
  action :install
end

%w{MySQL-client MySQL-devel}.each do |pkg|
  package pkg do
    action :install
    provider Chef::Provider::Package::Rpm
    source "/tmp/#{pkg}-#{node[:mysql][:version]}.rpm"
  end
end

template "/etc/profile.d/mysql_ps1.sh" do
  source "mysql_ps1.sh.erb"
  owner "root"
  group "root"
  mode "0644"
end