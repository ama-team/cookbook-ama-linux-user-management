# frozen_string_literal: true

# rubocop:disable Metrics/LineLength

require_relative 'private_key/remote'
require_relative '../../action/account/private_key/add'
require_relative '../../action/account/private_key/remove'
require_relative '../../action/account/private_key/purge'
require_relative '../../action/account/public_key/add'

module AMA
  module Chef
    module User
      class Planner
        class Account
          # This planner creates actions altering account private keys
          class PrivateKey
            def initialize
              @remote = Remote.new
            end

            # @param [AMA::Chef::User::Model::Account] account
            # @param [Hash{Symbol, Hash{Symbol, AMA::Chef::User::Model::PrivateKey}}] current_state
            # @param [Hash{Symbol, Hash{Symbol, AMA::Chef::User::Model::PrivateKey}}] desired_state
            def plan(account, current_state, desired_state)
              owners = current_state.keys | desired_state.keys
              actions = owners.flat_map do |owner|
                current_keys = current_state[owner] || {}
                desired_keys = desired_state[owner] || {}
                (current_keys.keys | desired_keys.keys).flat_map do |key|
                  process(account, current_keys[key], desired_keys[key])
                end
              end
              actions.push(ns::Purge.new(account)) if desired_state.empty?
              actions
            end

            # @param [AMA::Chef::User::Model::Account] account
            # @param [AMA::Chef::User::Model::PrivateKey] current_state
            # @param [AMA::Chef::User::Model::PrivateKey] desired_state
            def process(account, current_state, desired_state)
              current_remotes = current_state ? current_state.remotes : {}
              desired_remotes = desired_state ? desired_state.remotes : {}
              key = desired_state || current_state
              actions = @remote.plan(
                account,
                key,
                current_remotes,
                desired_remotes
              )
              if desired_state.nil?
                actions.push(ns::Remove.new(account, current_state))
              else
                actions.unshift(ns::Add.new(account, desired_state))
              end
              actions
            end

            def ns
              ::AMA::Chef::User::Action::Account::PrivateKey
            end

            def pubkey_ns
              ::AMA::Chef::User::Action::Account::PublicKey
            end
          end
        end
      end
    end
  end
end
