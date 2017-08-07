# frozen_string_literal: true

# rubocop:disable Metrics/LineLength

require_relative '../../action/account/privilege/grant'
require_relative '../../action/account/privilege/revoke'
require_relative '../../action/account/privilege/purge'

module AMA
  module Chef
    module User
      class Planner
        class Account
          # This planner creates actions altering account state
          class Privilege
            # @param [AMA::Chef::User::Model::Account] account
            # @param [Hash{Symbol, AMA::Chef::User::Model::Privilege}] current_state
            # @param [Hash{Symbol, AMA::Chef::User::Model::Privilege}] desired_state
            def plan(account, current_state, desired_state)
              actions = (current_state.keys | desired_state.keys).map do |key|
                process(account, current_state[key], desired_state[key])
              end
              actions.push(ns::Purge.new(account)) if desired_state.empty?
              actions
            end

            # @param [AMA::Chef::User::Model::Account] account
            # @param [AMA::Chef::User::Model::Privilege] current_state
            # @param [AMA::Chef::User::Model::Privilege] desired_state
            def process(account, current_state, desired_state)
              if desired_state.nil?
                ns::Revoke.new(account, current_state)
              else
                ns::Grant.new(account, desired_state)
              end
            end

            def ns
              ::AMA::Chef::User::Action::Account::Privilege
            end
          end
        end
      end
    end
  end
end
