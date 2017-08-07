# frozen_string_literal: true

require_relative 'group/privilege'
require_relative '../action/group/set_members'
require_relative '../action/group/append_members'
require_relative '../action/group/exclude_members'
require_relative '../action/group/remove'
require_relative '../model/policy'

module AMA
  module Chef
    module User
      class Planner
        # This planner creates actions altering group state
        class Group
          def initialize
            @privilege = Privilege.new
          end

          # @param [Hash{Symbol, AMA::Chef::User::Model::Group}] current_state
          # @param [Hash{Symbol, AMA::Chef::User::Model::Group}] desired_state
          def plan(current_state, desired_state)
            (current_state.keys | desired_state.keys).flat_map do |id|
              process(current_state[id], desired_state[id])
            end
          end

          private

          # @param [AMA::Chef::User::Model::Group] current_state
          # @param [AMA::Chef::User::Model::Group] desired_state
          def process(current_state, desired_state)
            actions = privilege_actions(current_state, desired_state)
            group = desired_state || current_state
            return [] if group.policy == Model::Policy::NONE
            if desired_state.nil?
              actions.push(*deletion_actions(current_state))
            else
              actions.push(*creation_actions(current_state, desired_state))
            end
            post_process_actions(actions)
          end

          def ns
            ::AMA::Chef::User::Action::Group
          end

          def creation_actions(current_state, desired_state)
            group = desired_state
            unless desired_state.policy == Model::Policy::EDIT
              return [ns::SetMembers.new(group)]
            end
            actions = [ns::AppendMembers.new(group)]
            current_members = current_state ? current_state.members : Set.new
            excluded_members = current_members - desired_state.members
            return actions if excluded_members.empty?
            actions.unshift(ns::ExcludeMembers.new(group, excluded_members))
          end

          def deletion_actions(current_state)
            if current_state.policy.remove?
              return [ns::Remove.new(current_state)]
            end
            return [] if current_state.members.empty?
            [ns::ExcludeMembers.new(current_state, current_state.members)]
          end

          def post_process_actions(actions)
            actions.each do |action|
              action.class_name = action.class.to_s
            end
            actions
          end

          def privilege_actions(current_state, desired_state)
            return [] if desired_state.nil? && !current_state.policy.remove?
            group = desired_state || current_state
            current = current_state.nil? ? {} : current_state.privileges
            desired = desired_state.nil? ? {} : desired_state.privileges
            @privilege.plan(group, current, desired)
          end
        end
      end
    end
  end
end
