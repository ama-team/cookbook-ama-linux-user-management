# frozen_string_literal: true

require 'set'

require_relative '../model/policy'

module AMA
  module Chef
    module User
      module State
        # Simple class that builds target state by applying partitions to
        # clients
        class Builder
          # @param [Hash{Symbol, AMA::Chef::User::Model::Client}] clients
          # @param [Hash{Symbol, AMA::Chef::User::Model::Partition}] partitions
          # @return [AMA::Chef::User::Model::State]
          def build(clients, partitions)
            state = Model::State.new
            partitions.values.each do |partition|
              process_partition(state, partition, clients)
            end
            clean_state(state)
            state
          end

          private

          # @param [AMA::Chef::User::Model::State] state
          # @param [AMA::Chef::User::Model::Partition] partition
          # @param [Hash<Symbol, AMA::Chef::User::Model::Client>] clients
          def process_partition(state, partition, clients)
            unless partition.policy.group == Model::Policy::NONE
              state.groups[partition.id] = extract_group(partition)
            end
            clients.values.each do |client|
              next unless partition.applies_to(client)
              apply_partition(state, client, partition)
            end
          end

          # @param [AMA::Chef::User::Model::State] state
          # @param [AMA::Chef::User::Model::Client] client
          # @param [AMA::Chef::User::Model::Partition] partition
          def apply_partition(state, client, partition)
            account = extract_account(client, partition)
            state.account!(client.id).merge(account)
            apply_impersonation(state, client, partition)
            return unless partition.policy.group != Model::Policy::NONE
            state.group(partition.id).members.add(account.id)
          end

          # @param [AMA::Chef::User::Model::State] state
          def clean_state(state)
            state.accounts.reject! do |_, account|
              account.policy == Model::Policy::NONE
            end
            state.groups.reject! do |_, group|
              group.policy == Model::Policy::NONE
            end
            state
          end

          def extract_group(partition)
            group = Model::Group.new(partition.id)
            group.policy = partition.policy.group
            group.privileges = partition.privileges.clone
            group
          end

          # rubocop:disable Metrics/AbcSize
          def extract_account(client, partition)
            account = Model::Account.new(client.id)
            account.policy = partition.policy.account
            unless client.public_keys.empty?
              account.public_keys!(client.id).merge!(client.public_keys)
            end
            unless client.private_keys.empty?
              account.private_keys!(client.id).merge!(client.private_keys)
            end
            if partition.policy.group.nothing? && !partition.privileges.empty?
              account.privileges = partition.privileges.clone
            end
            account
          end
          # rubocop:enable Metrics/AbcSize

          def apply_impersonation(state, client, partition)
            return if client.public_keys.empty?
            partition.impersonation.keys.each do |hijacked|
              package = Model::Account.new(hijacked)
              package.policy = :edit
              package.public_keys!(client.id).merge!(client.public_keys)
              state.account!(hijacked).merge(package)
            end
          end
        end
      end
    end
  end
end
