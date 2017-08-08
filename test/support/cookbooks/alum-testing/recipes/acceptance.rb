# frozen_string_literal: true

#
# Cookbook Name:: alum-testing
# Recipe:: acceptance
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require 'yaml'

history_id = node['history']
history = ::AMA::Chef::User::Test::Fixture::RunHistory.single(history_id)
opts = { include_sensitive_attributes: true }

history.runs.each do |run|
  id = run.id + 1
  clients = AMA::Entity::Mapper.normalize(run.clients, opts)
  partitions = AMA::Entity::Mapper.normalize(run.partitions, opts)

  ::Chef::Log.info("run #{id}:")
  ::Chef::Log.info('clients:')
  ::Chef::Log.info(clients.to_yaml)
  ::Chef::Log.info('partitions:')
  ::Chef::Log.info(partitions.to_yaml)

  ama_linux_user_management_accumulator "run #{id}" do
    clients clients
    partitions partitions
    context 'default'
  end

  ::Chef::Log.info("run #{id} end")
end
