# frozen_string_literal: true

#
# Cookbook Name:: alum-acceptance
# Recipe:: keys
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# frozen_string_literal: true

ama_linux_user_management 'keys' do
  accounts node['ama']['keys']['accounts']
  partitions node['ama']['keys']['partitions']
end
