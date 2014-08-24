#
# Cookbook Name:: play12
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

remote_file "/tmp/play-#{node['play12']['version']}.zip" do
  source "http://downloads.typesafe.com/play/#{node['play12']['version']}/play-#{node['play12']['version']}.zip"
end

bash "install play" do
  cwd "/tmp"
  user "root"
  code <<-BASH
    unzip play-#{node['play12']['version']}.zip -d /var/local
    chown -R #{node['play12']['user']}:#{node['play12']['group']} /var/local/play-#{node['play12']['version']}
  BASH
end

template "/etc/profile.d/play12.sh" do
  source "play12.sh.erb"
  owner "root"
  group "root"
  mode "0644"
end