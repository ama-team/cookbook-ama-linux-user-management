# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

require 'set'
require_relative '../lib/state/builder'
require_relative '../lib/state/persister'
require_relative '../lib/planner'
require_relative '../lib/model/partition'
require_relative '../lib/model/client'

resource_name :ama_linux_user_management_accumulator
default_action :manage

property :context, String, name_property: true
property :clients, Hash, default: {}, sensitive: true
property :partitions, Hash, default: {}, sensitive: true

action_class do
  def partitions
    type = [Hash, K: Symbol, V: AMA::Chef::User::Model::Partition]
    AMA::Entity::Mapper.map(new_resource.partitions, type)
  end

  def clients
    type = [Hash, K: Symbol, V: AMA::Chef::User::Model::Client]
    AMA::Entity::Mapper.map(new_resource.clients, type)
  end

  def persister
    return @persister if @persister
    @persister = ::AMA::Chef::User::State::Persister.new(node)
  end

  def state_builder
    return @state_builder if @state_builder
    @state_builder = ::AMA::Chef::User::State::Builder.new
  end

  def planner
    return @planner if @planner
    @planner = ::AMA::Chef::User::Planner.new
  end

  def current_state
    persister.retrieve(new_resource.context)
  end

  def desired_state
    state_builder.build(clients, partitions)
  end

  def to_resource_id
    "ama_linux_user_management_accumulator[#{new_resource.context}]"
  end

  def debug_message(message)
    ::Chef::Log.debug("#{to_resource_id}: #{message}")
  end

  def report_state(name, state)
    debug_message(
      "#{name} state: #{state.accounts.size} accounts, " \
      "#{state.groups.size} groups"
    )
  end
end

action :manage do
  debug_message(
    "processing #{clients.size} clients, #{partitions.size} partitions"
  )
  current_state = self.current_state
  desired_state = self.desired_state
  { current: current_state, desired: desired_state }.each do |name, state|
    report_state(name, state)
  end

  actions = planner.plan(current_state, desired_state)
  message = "Running #{to_resource_id} actions (total: #{actions.size})"
  ::Chef::Log.debug(message)
  actions.each do |action|
    ::Chef::Log.debug("Running action #{action}")
    action.apply(self)
  end

  converge_by 'Saving target state' do
    data = ::AMA::Entity::Mapper.normalize(desired_state)
    persister.persist(new_resource.context, data)
    debug_message("Processed #{to_resource_id}")
  end
end
