#
# Cookbook Name:: vagrant
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{
  telnet
  wget
  mailx
  zsh
  screen
  nmap
  nc
  tmux
  lsof
  htop
  dstat
  strace
  file
  man
  sysstat
  bind-utils
  colordiff
  rsync
  dmidecode
  pciutils
  tree
  tcpdump
  vim
  pbzip2
  expect
  zip
  unzip
  net-snmp-utils
  python-pip
  mosh
  multitail
}.each do |pkg|
  package pkg do
    action :install
  end
end