# frozen_string_literal: true

#
# Cookbook Name:: alum-acceptance
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

ama_linux_user_management 'default' do
  accounts node['ama']['accounts']
  partitions node['ama']['partitions']
end
