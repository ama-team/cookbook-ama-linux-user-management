# frozen_string_literal: true

# rubocop:disable Metrics/LineLength

require_relative '../../../action/account/private_key/remote/add'
require_relative '../../../action/account/private_key/remote/remove'
require_relative '../../../action/account/private_key/remote/purge'

module AMA
  module Chef
    module User
      class Planner
        class Account
          class PrivateKey
            # This planner creates actions altering private key remotes
            class Remote
              # @param [AMA::Chef::User::Model::Account] account
              # @param [AMA::Chef::User::Model::PrivateKey] private_key
              # @param [Hash{Symbol, AMA::Chef::User::Model::PrivateKey::Remote}] current_state
              # @param [Hash{Symbol, AMA::Chef::User::Model::PrivateKey::Remote}] desired_state
              def plan(account, private_key, current_state, desired_state)
                current_state ||= {}
                desired_state ||= {}
                actions = (current_state.keys | desired_state.keys).map do |key|
                  current = current_state[key]
                  desired = desired_state[key]
                  process(account, private_key, current, desired)
                end
                if desired_state.empty?
                  actions.push(ns::Purge.new(account, private_key))
                end
                actions
              end

              private

              # @param [AMA::Chef::User::Model::Account] account
              # @param [AMA::Chef::User::Model::PrivateKey] private_key
              # @param [AMA::Chef::User::Model::PrivateKey::Remote] current_state
              # @param [AMA::Chef::User::Model::PrivateKey::Remote] desired_state
              def process(account, private_key, current_state, desired_state)
                if desired_state.nil?
                  ns::Remove.new(account, private_key, current_state)
                else
                  ns::Add.new(account, private_key, desired_state)
                end
              end

              def ns
                ::AMA::Chef::User::Action::Account::PrivateKey::Remote
              end
            end
          end
        end
      end
    end
  end
end
