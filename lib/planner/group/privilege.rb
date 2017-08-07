# frozen_string_literal: true

# rubocop:disable Metrics/LineLength

require_relative '../../action/group/privilege/grant'
require_relative '../../action/group/privilege/revoke'
require_relative '../../action/group/privilege/purge'

module AMA
  module Chef
    module User
      class Planner
        class Group
          # Planner for group privileges
          class Privilege
            # @param [AMA::Chef::User::Model::Group] group
            # @param [Hash{Symbol, AMA::Chef::User::Model::Privilege}] current_state
            # @param [Hash{Symbol, AMA::Chef::User::Model::Privilege}] desired_state
            def plan(group, current_state, desired_state)
              actions = (current_state.keys | desired_state.keys).map do |type|
                process(group, current_state[type], desired_state[type])
              end
              actions.push(ns::Purge.new(group)) if desired_state.empty?
              actions
            end

            private

            # @param [AMA::Chef::User::Model::Group] group
            # @param [AMA::Chef::User::Model::Privilege] current_state
            # @param [AMA::Chef::User::Model::Privilege] desired_state
            def process(group, current_state, desired_state)
              return ns::Revoke.new(group, current_state) if desired_state.nil?
              ns::Grant.new(group, desired_state)
            end

            def ns
              ::AMA::Chef::User::Action::Group::Privilege
            end
          end
        end
      end
    end
  end
end
