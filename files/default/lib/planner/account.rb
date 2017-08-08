# frozen_string_literal: true

require_relative 'account/public_key'
require_relative 'account/private_key'
require_relative 'account/privilege'
require_relative '../action/account/create'
require_relative '../action/account/remove'

module AMA
  module Chef
    module User
      class Planner
        # This planner creates actions altering account state
        class Account
          def initialize
            @public_keys = PublicKey.new
            @private_keys = PrivateKey.new
            @privileges = Privilege.new
          end

          # @param [Hash{Symbol, AMA::Chef::User::Model::Account}] current_state
          # @param [Hash{Symbol, AMA::Chef::User::Model::Account}] desired_state
          def plan(current_state, desired_state)
            (current_state.keys | desired_state.keys).flat_map do |id|
              process(current_state[id], desired_state[id])
            end
          end

          # @param [AMA::Chef::User::Model::Account] current_state
          # @param [AMA::Chef::User::Model::Account] desired_state
          def process(current_state, desired_state)
            actions = [
              *process_public_keys(current_state, desired_state),
              *process_private_keys(current_state, desired_state),
              *process_privileges(current_state, desired_state)
            ]
            if !desired_state.nil?
              actions.unshift(ns::Create.new(desired_state))
            elsif current_state.policy.remove?
              actions.push(ns::Remove.new(current_state))
            end
            actions
          end

          private

          def ns
            ::AMA::Chef::User::Action::Account
          end

          # @param [AMA::Chef::User::Model::Account] current_state
          # @param [AMA::Chef::User::Model::Account] desired_state
          def process_public_keys(current_state, desired_state)
            return [] if desired_state.nil? && !current_state.policy.remove?
            account = desired_state || current_state
            current_keys = current_state ? current_state.public_keys : {}
            desired_keys = desired_state ? desired_state.public_keys : {}
            @public_keys.plan(account, current_keys, desired_keys)
          end

          # @param [AMA::Chef::User::Model::Account] current_state
          # @param [AMA::Chef::User::Model::Account] desired_state
          def process_private_keys(current_state, desired_state)
            return [] if desired_state.nil? && !current_state.policy.remove?
            account = desired_state || current_state
            current_keys = current_state ? current_state.private_keys : {}
            desired_keys = desired_state ? desired_state.private_keys : {}
            @private_keys.plan(account, current_keys, desired_keys)
          end

          # @param [AMA::Chef::User::Model::Account] current_state
          # @param [AMA::Chef::User::Model::Account] desired_state
          def process_privileges(current_state, desired_state)
            return [] if desired_state.nil? && !current_state.policy.remove?
            account = desired_state || current_state
            current_privileges = current_state ? current_state.privileges : {}
            desired_privileges = desired_state ? desired_state.privileges : {}
            @privileges.plan(account, current_privileges, desired_privileges)
          end
        end
      end
    end
  end
end
