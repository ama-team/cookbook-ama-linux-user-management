# frozen_string_literal: true

resource_name :ama_linux_user_management
default_action :manage

# rubocop:disable Metrics/LineLength
property :clients, [Hash, NilClass], required: false, default: {}, sensitive: true
property :partitions, [Hash, NilClass], required: false, default: {}, sensitive: true
property :context, [String], default: 'default'
# rubocop:enable Metrics/LineLength

action_class do
  def clients
    clients = new_resource.clients
    unless clients
      data_bag_name = node['ama']['user']['client-bag'] || 'clients'
      clients = data_bag(data_bag_name).map do |id|
        [id, data_bag_item(data_bag_name, id)]
      end
      clients = Hash[clients]
    end
    type = AMA::Chef::User::Model::Client
    AMA::Entity::Mapper.map(clients, [Hash, K: Symbol, V: type])
  end

  def partitions
    partitions = new_resource.partitions
    unless partitions
      cursor = node['ama'] || {}
      cursor = cursor['user'] || {}
      partitions = cursor['partitions'] || {}
    end
    type = AMA::Chef::User::Model::Partition
    AMA::Entity::Mapper.map(partitions, [Hash, K: Symbol, V: type])
  end

  def compute_resource_id
    "ama_linux_user_management[#{new_resource.name}]"
  end
end

action :manage do
  begin
    accumulator = resources(ama_linux_user_management_internal: context)
    accumulator.clients = accumulator.clients.merge(clients).freeze
    accumulator.partitions = accumulator.partitions.merge(partitions).freeze
  rescue Chef::Exceptions::ResourceNotFound
    resource_name = "ama_linux_user_management_accumulator[#{context}]"
    log "scheduling #{resource_name} execution" do
      level :debug
      notifies :manage, resource_name, :delayed
    end
    accumulator = ama_linux_user_management_accumulator context do
      action :nothing
    end
  end
  accumulator.clients = accumulator.clients.merge(clients).freeze
  accumulator.partitions = accumulator.partitions.merge(partitions).freeze
end
