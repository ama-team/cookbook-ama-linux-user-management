# frozen_string_literal: true

# rubocop:disable Metrics/LineLength

require_relative '../../action/account/public_key/add'
require_relative '../../action/account/public_key/remove'
require_relative '../../action/account/public_key/purge'

module AMA
  module Chef
    module User
      class Planner
        class Account
          # This planner creates actions altering account privileges
          class PublicKey
            # @param [AMA::Chef::User::Model::Account] account
            # @param [Hash{Symbol, Hash{Symbol, AMA::Chef::User::Model::PublicKey}}] current_state
            # @param [Hash{Symbol, Hash{Symbol, AMA::Chef::User::Model::PublicKey}}] desired_state
            def plan(account, current_state, desired_state)
              owners = current_state.keys | desired_state.keys
              actions = owners.flat_map do |owner|
                current_keys = current_state[owner] || {}
                desired_keys = desired_state[owner] || {}
                (current_keys.keys | desired_keys.keys).map do |key|
                  process(account, current_keys[key], desired_keys[key])
                end
              end
              actions.push(ns::Purge.new(account)) if desired_state.empty?
              actions
            end

            # @param [AMA::Chef::User::Model::Account] account
            # @param [AMA::Chef::User::Model::PublicKey] current_state
            # @param [AMA::Chef::User::Model::PublicKey] desired_state
            def process(account, current_state, desired_state)
              if desired_state.nil?
                ns::Remove.new(account, current_state)
              else
                ns::Add.new(account, desired_state)
              end
            end

            def ns
              ::AMA::Chef::User::Action::Account::PublicKey
            end
          end
        end
      end
    end
  end
end
