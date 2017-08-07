# frozen_string_literal: true

#
# Cookbook Name:: alum-acceptance
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

root = (0..1).reduce(__dir__) { |carrier| ::File.dirname(carrier) }
path = "#{root}/ama-linux-user-management/files/vendor/default/gems"
pattern = "#{path}/**/lib"
puts Dir.entries(path)
Dir.glob(pattern).each do |path|
  puts path
  $LOAD_PATH.unshift(path)
end

history_id = node['history']
history = ::AMA::Chef::User::Test::Fixture::RunHistory.single(history_id)

history.runs.each do |run|
  id = run.id + 1
  ama_linux_user_management "run #{id}" do
    accounts run.accounts
    partitions run.partitions
    context 'default'
  end
end
