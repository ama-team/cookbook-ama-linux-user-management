# frozen_string_literal: true

ama_linux_user_management_accumulator 'default' do
  buffer = data_bag('clients').map do |id|
    [id, data_bag_item('clients', id)]
  end
  clients Hash[buffer]

  buffer = node['ama']['user']['partitions']
  type = AMA::Chef::User::Model::Partition
  buffer = AMA::Entity::Mapper.map(buffer, [Hash, K: Symbol, V: type])
  partitions buffer
end
